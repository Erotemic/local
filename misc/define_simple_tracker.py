

def main():
    import pipedef
    pipe = pipedef.Pipeline()

    # ============================== GLOBAL PROPERTIES =================================
    # global pipeline config
    pipe.config = {
        '_pipeline:_edge': {'capacity': 5},
    }

    # ============================== INPUT FRAME LIST ==================================
    input = pipe.add_process(name='input', type='frame_list_input', config={
        'image_reader:type' : 'vxl',
        'image_list_file'   : 'input_list.txt',
        'frame_time'        : 0.03333,
    })
    input.iports.define()
    input.oports.define('image', 'timestamp', 'image_file_name')

    # ================================== DETECTOR ======================================
    detector = pipe.add_process(name='detector', type='image_object_detector', config={
        'detector:type': 'darknet',
        # Network config
        ':detector:darknet:net_config'  :  '../detector_pipelines/models/model2.cfg',
        ':detector:darknet:weight_file' :  '../detector_pipelines/models/model2.weights',
        ':detector:darknet:class_names' : '../detector_pipelines/models/scallop_and_fish.lbl',

        # Detector parameters
        ':detector:darknet:thresh'      :  0.001,
        ':detector:darknet:hier_thresh' :  0.001,
        ':detector:darknet:gpu_index'   :  0,

        # Image scaling parameters
        ':detector:darknet:resize_option': 'maintain_ar',
        ':detector:darknet:resize_ni':    544,
        ':detector:darknet:resize_nj':    544,
        ':detector:darknet:scale':        1.0,
    })
    detector.iports.define('image')
    detector.oports.define('detected_object_set')

    detector_writer = pipe.add_process(name='detector_writer', type='detected_object_output', config={
        # Type of file to output
        ':file_name':     'output/individual_detections.kw18',
        ':writer:type':   'kw18',

        # Write out FSO classifications alongside tracks
        ':writer:kw18:write_tot':         True,
        ':writer:kw18:tot_field1_ids':    'fish',
        ':writer:kw18:tot_field2_ids':    'scallop',
    })
    detector_writer.iports.define('detected_object_set', 'image_file_name')
    detector_writer.oports.define()

    input.oports.connect({
        'image': detector.iports['image'],
        'image_file_name': detector_writer.iports['image_file_name'],
    })
    detector.oports.connect({
        'detected_object_set': detector_writer.iports['detected_object_set'],
    })

    # Note these other alternative ways of creating edges
    # input.oports['image'].connect(detector.iports['image'])
    # input.oports['image'].connect(detector_writer.iports['image_file_name'])
    # detector.oports['detected_object_set'].connect(detector_writer.iports['detected_object_set'])

    # input.oports['image'].connect(detector.iports['image'])  # closer to syntax of a .pipe file
    # input.oports.connect({'image': detector.iports['image']})  # closer to syntax of a .pipe file
    # detector.iports.connect(**input.oports)  # can use if input and output ports share names
    # detector.iports.connect({'image': input.oports['image']}) # closer to the syntax of a function call

    # ================================ CORE TRACKER  ===================================
    detection_descriptor = pipe.add_process(name='detection_descriptor', type='compute_track_descriptors')
    detection_descriptor.config = {
        ':inject_to_detections'             :          True,
        ':computer:type'                    :          'burnout',
        ':computer:burnout:config_file'     :          'detection_descriptors.conf',
    }
    detection_descriptor.iports.define('image', 'timestamp', 'detected_object_set')
    detection_descriptor.oports.define('detected_object_set')

    tracker = pipe.add_process(name='tracker', type='compute_association_matrix')
    tracker.config = '''
      :matrix_generator:type                       from_features
      :matrix_generator:from_features:max_distance 40

      block matrix_generator:from_features:filter
        :type                                      class_probablity_filter
        :class_probablity_filter:threshold         0.001
        :class_probablity_filter:keep_all_classes  false
        :class_probablity_filter:keep_classes      fish;scallop
      endblock
    '''
    tracker.iports.define('image', 'timestamp', 'detected_object_set', 'object_track_set')
    tracker.oports.define('matrix_d', 'object_track_set', 'detected_object_set')

    track_associator = pipe.add_process(name='track_associator', type='associate_detections_to_tracks')
    track_associator.config = '''
      :track_associator:type                       threshold
      :track_associator:threshold:threshold        100.0
      :track_associator:threshold:higher_is_better false
    '''
    track_associator.iports.define('image', 'timestamp', 'matrix_d', 'object_track_set', 'detected_object_set')
    track_associator.oports.define('object_track_set', 'unused_detections')

    track_initializer = pipe.add_process(name='track_initializer', type='initialize_object_tracks')
    track_initializer.config = '''
      :track_initializer:type                      threshold

      block track_initializer:threshold:filter
        :type                                      class_probablity_filter
        :class_probablity_filter:threshold         0.001
        :class_probablity_filter:keep_all_classes  false
        :class_probablity_filter:keep_classes      fish;scallop
      endblock
    '''
    track_initializer.iports.define('image', 'timestamp', 'object_track_set', 'detected_object_set')
    track_initializer.oports.define('object_track_set')

    # To use the star notation the input ports and output ports must have the
    # same name.  Currently you must also define the ports. Eventually we might
    # read them from sprokit.

    # Connect inputs to detection descriptor
    detection_descriptor.iports.connect(**input.oports, **detector.oports)

    # Connect inputs to tracker
    tracker.iports.connect(**input.oports, **detection_descriptor.oports, **track_initializer.oports)

    # Connect inputs to track_associator
    track_associator.iports.connect(**input.oports, **tracker.oports)

    # Connect inputs to track_initializer
    track_initializer.iports.connect(
        detected_object_set=track_associator.oports['unused_detections'],
        **input.oports, **track_associator.oports)

    # ================================= INDEX DATA  ====================================
    track_writer = pipe.add_process(name='track_writer', type='write_object_track')
    track_writer.iports.define('object_track_set')
    track_writer.config = '''
      :file_name                        output_tracks.kw18
      :writer:type                      kw18
    '''

    # Connect inputs to track writer
    track_writer.iports.connect(**track_initializer.oports)

    return pipe

if __name__ == '__main__':
    r"""
    CommandLine:

        source ~/code/VIAME/build/install/setup_viame.sh
        cd /home/joncrall/code/VIAME/examples/tracking_pipelines
        ~/code/VIAME/build/install/bin/pipe_to_dot -p simple_tracker.pipe -o g.dot
        dot -Tpng g.dot > g.png

        python ~/code/VIAME/examples/tracking_pipelines/define_simple_tracker.py
    """
    pipe = main()

    pipe.write('auto_simple_tracker.pipe')

    pipe.draw_graph('pipeline.png')
    import ubelt as ub
    ub.startfile('pipeline.png')
