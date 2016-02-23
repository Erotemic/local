# -*- coding: utf-8 -*-
from __future__ import absolute_import, division, print_function, unicode_literals
import utool as ut


def other_flann_ctypes_diff():
    header = ut.codeblock(
        r'''
        #Copyright 2008-2009  Marius Muja (mariusm@cs.ubc.ca). All rights reserved.
        #Copyright 2008-2009  David G. Lowe (lowe@cs.ubc.ca). All rights reserved.
        #
        #THE BSD LICENSE
        #
        #Redistribution and use in source and binary forms, with or without
        #modification, are permitted provided that the following conditions
        #are met:
        #
        #1. Redistributions of source code must retain the above copyright
        #   notice, this list of conditions and the following disclaimer.
        #2. Redistributions in binary form must reproduce the above copyright
        #   notice, this list of conditions and the following disclaimer in the
        #   documentation and/or other materials provided with the distribution.
        #
        #THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
        #IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
        #OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
        #IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
        #INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
        #NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
        #DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
        #THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        #(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
        #THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

        #from ctypes import *
        #from ctypes.util import find_library
        from numpy import (float32, float64, uint8, int32, require)
        #import ctypes
        #import numpy as np
        from ctypes import (Structure, c_char_p, c_int, c_float, c_uint, c_long,
                            c_void_p, cdll, POINTER)
        from numpy.ctypeslib import ndpointer
        import os
        import sys

        STRING = c_char_p


        class CustomStructure(Structure):
            """
                This class extends the functionality of the ctype's structure
                class by adding custom default values to the fields and a way of translating
                field types.
            """
            _defaults_ = {}
            _translation_ = {}

            def __init__(self):
                Structure.__init__(self)
                self.__field_names = [ f for (f, t) in self._fields_]
                self.update(self._defaults_)

            def update(self, dict):
                for k, v in dict.items():
                    if k in self.__field_names:
                        setattr(self, k, self.__translate(k, v))
                    else:
                        raise KeyError('No such member: ' + k)

            def __getitem__(self, k):
                if k in self.__field_names:
                    return self.__translate_back(k, getattr(self, k))

            def __setitem__(self, k, v):
                if k in self.__field_names:
                    setattr(self, k, self.__translate(k, v))
                else:
                    raise KeyError('No such member: ' + k)

            def keys(self):
                return self.__field_names

            def __translate(self, k, v):
                if k in self._translation_:
                    if v in self._translation_[k]:
                        return self._translation_[k][v]
                return v

            def __translate_back(self, k, v):
                if k in self._translation_:
                    for tk, tv in self._translation_[k].items():
                        if tv == v:
                            return tk
                return v


        class FLANNParameters(CustomStructure):
            _fields_ = [
                ('algorithm', c_int),
                ('checks', c_int),
                ('eps', c_float),
                ('sorted', c_int),
                ('max_neighbors', c_int),
                ('cores', c_int),
                ('trees', c_int),
                ('leaf_max_size', c_int),
                ('branching', c_int),
                ('iterations', c_int),
                ('centers_init', c_int),
                ('cb_index', c_float),
                ('target_precision', c_float),
                ('build_weight', c_float),
                ('memory_weight', c_float),
                ('sample_fraction', c_float),
                ('table_number_', c_uint),
                ('key_size_', c_uint),
                ('multi_probe_level_', c_uint),
                ('log_level', c_int),
                ('random_seed', c_long),
            ]
            _defaults_ = {
                'algorithm' : 'kdtree',
                'checks' : 32,
                'eps' : 0.0,
                'sorted' : 1,
                'max_neighbors' : -1,
                'cores' : 0,
                'trees' : 1,
                'leaf_max_size' : 4,
                'branching' : 32,
                'iterations' : 5,
                'centers_init' : 'random',
                'cb_index' : 0.5,
                'target_precision' : 0.9,
                'build_weight' : 0.01,
                'memory_weight' : 0.0,
                'sample_fraction' : 0.1,
                'table_number_': 12,
                'key_size_': 20,
                'multi_probe_level_': 2,
                'log_level' : 'warning',
                'random_seed' : -1
            }
            _translation_ = {
                'algorithm'     : {'linear'    : 0, 'kdtree'    : 1, 'kmeans'    : 2, 'composite' : 3, 'kdtree_single' : 4, 'hierarchical': 5, 'lsh': 6, 'saved': 254, 'autotuned' : 255, 'default'   : 1},
                'centers_init'  : {'random'    : 0, 'gonzales'  : 1, 'kmeanspp'  : 2, 'default'   : 0},
                'log_level'     : {'none'      : 0, 'fatal'     : 1, 'error'     : 2, 'warning'   : 3, 'info'      : 4, 'default'   : 2, 'debug': 5}
            }


        default_flags = ['C_CONTIGUOUS', 'ALIGNED']
        allowed_types = [ float32, float64, uint8, int32]

        FLANN_INDEX = c_void_p


        def load_flann_library():

            root_dir = os.path.abspath(os.path.dirname(__file__))

            tried_paths = []

            libnames = ['libflann.so']
            libdir = 'lib'
            if sys.platform == 'win32':
                libnames = ['flann.dll', 'libflann.dll']
            elif sys.platform == 'darwin':
                libnames = ['libflann.dylib']

            while root_dir is not None:
                for libname in libnames:
                    try:
                        libpath = os.path.join(root_dir, libdir, libname)
                        #print('Trying %s' % (libpath,))
                        tried_paths.append(libpath)
                        flannlib = cdll[libpath]
                        return flannlib
                    except Exception:
                        pass
                    try:
                        libpath = os.path.join(root_dir, 'build', libdir, libname)
                        #print('Trying %s' % (libpath,))
                        tried_paths.append(libpath)
                        flannlib = cdll[libpath]
                        return flannlib
                    except Exception:
                        pass
                tmp = os.path.dirname(root_dir)
                if tmp == root_dir:
                    root_dir = None
                else:
                    root_dir = tmp

            # if we didn't find the library so far, try loading without
            # a full path as a last resort
            for libname in libnames:
                try:
                    #print('Trying %s' % (libname,))
                    tried_paths.append(libname)
                    flannlib = cdll[libname]
                    return flannlib
                except:
                    pass

            return None

        flannlib = load_flann_library()
        if flannlib is None:
            raise ImportError('Cannot load dynamic library. Did you compile FLANN?')


        class FlannLib(object):
            pass

        flann = FlannLib()

        type_mappings = ( ('float', 'float32'),
                          ('double', 'float64'),
                          ('byte', 'uint8'),
                          ('int', 'int32') )


        def define_functions(fmtstr):
            try:
                for type_ in type_mappings:
                    # Special case for doubles
                    if type_[0] == 'double':
                        restype = 'float64'
                    else:
                        restype = 'float32'

                    source = fmtstr % {'C': type_[0], 'numpy': type_[1], 'restype': restype}
                    code = compile(source, '<string>', 'exec')
                    eval(code)
            except AttributeError:
                print('+=========')
                print('Error compling code')
                print('+ format string ---------')
                print(fmtstr)
                print('+ failing instance ---------')
                print(source)
                print('L_________')
                raise
        '''
    )

    footer = ut.codeblock(
        '''
        def ensure_2d_array(arr, flags, **kwargs):
            arr = require(arr, requirements=flags, **kwargs)
            if len(arr.shape) == 1:
                arr = arr.reshape(-1, arr.size)
            return arr
        '''
    )
    return header, footer


def indexpy_extras():
    '''
    def __init__(self, **kwargs):
        """
        Constructor for the class and returns a class that can bind to
        the flann libraries.  Any keyword arguments passed to __init__
        override the global defaults given.
        """

        self.__rn_gen.seed()

        self.__curindex = None
        self.__curindex_data = None  # pointer to keep the numpy data alive
        self.__added_data = []  # contained to keep any added numpy data alive
        self.__removed_ids = []  # contains the point ids that have been removed
        self.__curindex_type = None

        self.__flann_parameters = FLANNParameters()
        self.__flann_parameters.update(kwargs)

    def __del__(self):
        #print('FLANN OBJECT IS DELETED')
        self.delete_index()

    def get_indexed_shape(self):
        """ returns the shape of the data being indexed """
        npts, dim = self.__curindex_data.shape
        for _extra in self.__added_data:
            npts += _extra.shape[0]
        npts -= len(self.__removed_ids)
        return npts, dim
    '''
    pass


def define_flann_bindings(binding_name):
    """
    Define the binding names for flann
    """
    # default c source
    c_source = None
    optional_args = None
    c_source_part = None
    py_source = None
    py_alias = None
    py_args = None
    pydoc = None

    cpp_param_doc = {
        'cols': 'number of columns in the dataset (feature dimensionality)',
        'dataset': 'pointer to a data set stored in row major order',
        'dists': ut.packtext(
            '''pointer to matrix for the distances of the nearest neighbors of
            the testset features in the dataset'''),
        'flann_params': 'generic flann parameters',
        'index_ptr': 'the index (constructed previously using flann_build_index)',
        'nn': 'how many nearest neighbors to return',
        'rebuild_threshold': ut.packtext(
            '''reallocs index when it grows by factor of `rebuild_threshold`.
            A smaller value results is more space efficient but less
            computationally efficient. Must be greater than 1.'''),
        'result_ids': ut.packtext(
            '''pointer to matrix for the indices of the nearest neighbors of
            the testset features in the dataset (must have tcount number of
            rows and nn number of columns)'''),
        'rows': 'number of rows (features) in the dataset',
        'tcount': ut.packtext(
            '''number of rows (features) in the query dataset (same
            dimensionality as features in the dataset)'''),
        'testset': 'pointer to a query set stored in row major order',
        'level':  'verbosity level'
    }

    standard_csource = ut.codeblock(
        r'''
        try {{
            if (index_ptr==NULL) {{
                throw FLANNException("Invalid index");
            }}
            Index<Distance>* index = (Index<Distance>*)index_ptr;
            return index->{cpp_binding_name}();
        }}
        catch (std::runtime_error& e) {{
            Logger::error("Caught exception: %s\n",e.what());
            throw;
        }}
        '''
    )

    return_doc = None

    cpp_binding_name = binding_name
    zero_success = 'zero or a number <0 for error'

    if binding_name == 'clean_removed_points':
        cpp_binding_name = ut.to_camel_case(binding_name)
        return_type = 'void'
        docstr = 'Deletes removed points in index?'
        binding_argnames = ['index_ptr']
        c_source = standard_csource
    elif binding_name == 'veclen':
        return_type = 'int'
        docstr = 'Returns number of features in this index'
        binding_argnames = ['index_ptr']
        c_source = standard_csource
    elif binding_name == 'size':
        return_type = 'int'
        docstr = 'returns The dimensionality of the features in this index.'
        binding_argnames = ['index_ptr']
        c_source = standard_csource
    elif binding_name == 'getType':
        return_type = 'flann_algorithm_t'
        docstr = 'returns The index type (kdtree, kmeans,...)'
        binding_argnames = ['index_ptr']
        c_source = standard_csource
    elif binding_name == 'used_memory':
        docstr = ut.codeblock(
            '''
            Returns the amount of memory (in bytes) used by the index

            index_ptr = pointer to pre-built index.

            Returns: int
            '''
        )
        c_source = ut.codeblock(
            r'''
            try {{
                if (index_ptr==NULL) {{
                    throw FLANNException("Invalid index");
                }}
                Index<Distance>* index = (Index<Distance>*)index_ptr;
                return index->usedMemory();
            }}
            catch (std::runtime_error& e) {{
                Logger::error("Caught exception: %s\n",e.what());
                return -1;
            }}
            '''
        )
        py_source = ut.codeblock(
            '''
            if self.__curindex is None:
                return 0
            return flann.used_memory[self.__curindex_type](self.__curindex)
            ''')
        binding_argnames = ['index_ptr']
        return_type = 'int'
    elif binding_name == 'add_points':
        c_source = ut.codeblock(
            r'''
            typedef typename Distance::ElementType ElementType;
            try {{
                if (index_ptr==NULL) {{
                    throw FLANNException("Invalid index");
                }}
                Index<Distance>* index = (Index<Distance>*)index_ptr;
                Matrix<ElementType> points = Matrix<ElementType>(points, rows, index->veclen());
                index->addPoints(points, rebuild_threshold);
                return 0;
            }}
            catch (std::runtime_error& e) {{
                Logger::error("Caught exception: %s\n",e.what());
                return -1;
            }}
            '''
        )
        py_source = ut.codeblock(
            '''
            if new_pts.dtype.type not in allowed_types:
                raise FLANNException('Cannot handle type: %s' % new_pts.dtype)
            if new_pts.dtype != self.__curindex_type:
                raise FLANNException('New points must have the same type')
            new_pts = ensure_2d_array(new_pts, default_flags)
            rows = new_pts.shape[0]
            flann.add_points[self.__curindex_type](self.__curindex, new_pts, rows, rebuild_threshold)
            return self.__added_data.append(new_pts)
            ''')
        #return_type = 'void'
        return_type = 'int'
        docstr = 'Adds points to pre-built index.'
        if False:
            binding_argnames = [
                'index_ptr',
                'points',
                'rows',
                'cols',  # TODO: can remove
                'rebuild_threshold',
            ]
        else:
            binding_argnames = [
                'index_ptr',
                'points',
                'rows',
                'rebuild_threshold',
            ]
        return_doc = '0 if success otherwise -1'
        py_args = ['new_pts', 'rebuild_threshold=2.']
        cpp_param_doc['points'] = 'pointer to array of points'
    elif binding_name == 'remove_point':
        c_source = ut.codeblock(
            r'''
            size_t point_id(point_id_uint);
            try {{
                if (index_ptr==NULL) {{
                    throw FLANNException("Invalid index");
                }}
                Index<Distance>* index = (Index<Distance>*)index_ptr;
                index->removePoint(point_id);
                return 0;
            }}
            catch (std::runtime_error& e) {{
                Logger::error("Caught exception: %s\n",e.what());
                return -1;
            }}
            '''
        )
        py_source = ut.codeblock(
            '''
            flann.remove_point[self.__curindex_type](self.__curindex, point_id)
            self.__removed_ids.append(point_id)
            ''')
        #return_type = 'void'
        return_type = 'int'
        docstr = 'Removes a point from the index'
        return_doc = zero_success
        cpp_param_doc['point_id'] = 'point id to be removed'
        cpp_param_doc['index_ptr'] = 'The index that should be modified'
        binding_argnames = ['index_ptr', 'point_id']
    elif binding_name == 'remove_points':
        c_source = ut.codeblock(
            r'''
            typedef typename Distance::ElementType ElementType;
            try {{
                if (index_ptr==NULL) {{
                    thow FLANNException("Invalid index");
                }}
                Index<Distance>* index = (Index<Distance>*)index_ptr;
                index->removePoints(id_list, num);
                return;
            }}
            catch (std::runtime_error& e) {{
                Logger::error("Caught exception: %s\n",e.what());
                return;
            }}
            '''
        )
        py_source = ut.codeblock(
            '''
            id_list = np.array(id_list, dtype=np.int32)
            num = len(id_list)

            flann.remove_points[self.__curindex_type](self.__curindex, id_list, num)
            self.__removed_ids.extend(id_list)
            ''')
        cpp_param_doc['index_ptr'] = 'The index that should be modified'
        cpp_param_doc['id_list'] = 'list of point ids to be removed'
        cpp_param_doc['num'] = 'number of points in id_list'
        docstr = 'Removes multiple points from the index'
        return_doc = 'void'
        py_args = ['id_list']
        return_type = 'void'
        binding_argnames = ['index_ptr', 'id_list', 'num']
    elif binding_name == 'compute_cluster_centers':
        docstr = ut.textblock(
            r'''
            Clusters the features in the dataset using a hierarchical kmeans
            clustering approach. This is significantly faster than using a
            flat kmeans clustering for a large number of clusters.
            ''')
        c_source = ut.codeblock(
            r'''
            typedef typename Distance::ElementType ElementType;
            typedef typename Distance::ResultType DistanceType;
            try {
                init_flann_parameters(flann_params);

                Matrix<ElementType> inputData(dataset,rows,cols);
                KMeansIndexParams params(flann_params->branching, flann_params->iterations, flann_params->centers_init, flann_params->cb_index);
                Matrix<DistanceType> centers(result_centers, clusters,cols);
                int clusterNum = hierarchicalClustering<Distance>(inputData, centers, params, d);

                return clusterNum;
            }
            catch (std::runtime_error& e) {
                Logger::error("Caught exception: %s\n",e.what());
                return -1;
            }
            '''.replace('{', '{{').replace('}', '}}')
        )
        py_source = ut.codeblock(
            '''
            # First verify the paremeters are sensible.

            if pts.dtype.type not in allowed_types:
                raise FLANNException('Cannot handle type: %s' % pts.dtype)

            if int(branch_size) != branch_size or branch_size < 2:
                raise FLANNException('branch_size must be an integer >= 2.')

            branch_size = int(branch_size)

            if int(num_branches) != num_branches or num_branches < 1:
                raise FLANNException('num_branches must be an integer >= 1.')

            num_branches = int(num_branches)

            if max_iterations is None:
                max_iterations = -1
            else:
                max_iterations = int(max_iterations)

            # init the arrays and starting values
            pts = ensure_2d_array(pts, default_flags)
            npts, dim = pts.shape
            num_clusters = (branch_size - 1) * num_branches + 1

            if pts.dtype.type == np.float64:
                result = np.empty((num_clusters, dim), dtype=np.float64)
            else:
                result = np.empty((num_clusters, dim), dtype=np.float32)

            # set all the parameters appropriately

            self.__ensureRandomSeed(kwargs)

            params = {'iterations': max_iterations,
                      'algorithm': 'kmeans',
                      'branching': branch_size,
                      'random_seed': kwargs['random_seed']}

            self.__flann_parameters.update(params)

            numclusters = flann.compute_cluster_centers[pts.dtype.type](
                pts, npts, dim, num_clusters, result,
                pointer(self.__flann_parameters))
            if numclusters <= 0:
                raise FLANNException('Error occured during clustering procedure.')

            if dtype is None:
                return result
            else:
                return dtype(result)
            ''').replace('}', '}}').replace('{', '{{')
        return_doc = ut.packtext(
            '''number of clusters computed or a number <0 for error. This
            number can be different than the number of clusters requested, due
            to the way hierarchical clusters are computed. The number of
            clusters returned will be the highest number of the form
            (branch_size-1)*K+1 smaller than the number of clusters
            requested.''')
        cpp_param_doc['clusters'] = 'number of cluster to compute'
        cpp_param_doc['result_centers'] = 'memory buffer where the output cluster centers are stored'
        cpp_param_doc['flann_params'] = 'generic flann parameters and index_params used to specify the kmeans tree parameters (branching factor, max number of iterations to use)'
        return_type = 'int'
        binding_argnames = ['dataset', 'rows', 'cols', 'clusters', 'result_centers', 'flann_params']
        optional_args = ['Distance d = Distance()']
        py_alias = 'hierarchical_kmeans'
        py_args = 'pts, branch_size, num_branches, max_iterations=None, dtype=None, **kwargs'.split(', ')
    elif binding_name == 'radius_search':
        docstr = ut.codeblock(
            r'''
            Performs an radius search using an already constructed index.

            In case of radius search, instead of always returning a predetermined
            number of nearest neighbours (for example the 10 nearest neighbours), the
            search will return all the neighbours found within a search radius
            of the query point.

            The check parameter in the FLANNParameters below sets the level of approximation
            for the search by only visiting "checks" number of features in the index
            (the same way as for the KNN search). A lower value for checks will give
            a higher search speedup at the cost of potentially not returning all the
            neighbours in the specified radius.
            ''')
        c_source = ut.codeblock(
            r'''
            typedef typename Distance::ElementType ElementType;
            typedef typename Distance::ResultType DistanceType;

            try {{
                init_flann_parameters(flann_params);
                if (index_ptr==NULL) {{
                    throw FLANNException("Invalid index");
                }}
                Index<Distance>* index = (Index<Distance>*)index_ptr;

                Matrix<int> m_result_ids(result_ids, 1, max_nn);
                Matrix<DistanceType> m_dists(dists1d, 1, max_nn);
                SearchParams search_params = create_search_params(flann_params);
                int count = index->radiusSearch(Matrix<ElementType>(query1d, 1, index->veclen()),
                                                m_result_ids,
                                                m_dists, radius, search_params );


                return count;
            }}
            catch (std::runtime_error& e) {{
                Logger::error("Caught exception: %s\n",e.what());
                return -1;
            }}
            ''')
        py_source = ut.codeblock(
            '''
            if self.__curindex is None:
                raise FLANNException(
                    'build_index(...) method not called first or current index deleted.')

            if query.dtype.type not in allowed_types:
                raise FLANNException('Cannot handle type: %s' % query.dtype)

            if self.__curindex_type != query.dtype.type:
                raise FLANNException('Index and query must have the same type')

            npts, dim = self.get_indexed_shape()
            assert(query.shape[0] == dim), 'data and query must have the same dims'

            result = np.empty(npts, dtype=index_type)
            if self.__curindex_type == np.float64:
                dists = np.empty(npts, dtype=np.float64)
            else:
                dists = np.empty(npts, dtype=np.float32)

            self.__flann_parameters.update(kwargs)

            nn = flann.radius_search[
                self.__curindex_type](
                self.__curindex, query, result, dists, npts, radius,
                pointer(self.__flann_parameters))

            return (result[0:nn], dists[0:nn])
            ''')
        cpp_param_doc['index_ptr'] = 'the index'
        cpp_param_doc['query1d'] = 'query point'
        cpp_param_doc['dists1d'] = 'similar, but for storing distances'
        cpp_param_doc['result_ids'] = 'array for storing the indices found (will be modified)'
        cpp_param_doc['max_nn'] = 'size of arrays result_ids and dists1d'
        cpp_param_doc['radius'] = 'search radius (squared radius for euclidian metric)'
        return_doc = 'number of neighbors found or <0 for an error'
        return_type = 'int'
        binding_argnames = ['index_ptr', 'query1d', 'result_ids', 'dists1d', 'max_nn',
                            'radius', 'flann_params', ]
        py_alias = 'nn_radius'
        py_args = 'query, radius, **kwargs'.split(', ')

    elif binding_name == 'find_nearest_neighbors_index':
        c_source = ut.codeblock(
            r'''
            typedef typename Distance::ElementType ElementType;
            typedef typename Distance::ResultType DistanceType;

            try {
                init_flann_parameters(flann_params);
                if (index_ptr==NULL) {
                    throw FLANNException("Invalid index");
                }
                Index<Distance>* index = (Index<Distance>*)index_ptr;

                Matrix<int> m_indices(result_ids,tcount, nn);
                Matrix<DistanceType> m_dists(dists, tcount, nn);

                SearchParams search_params = create_search_params(flann_params);
                index->knnSearch(Matrix<ElementType>(testset, tcount, index->veclen()),
                                 m_indices,
                                 m_dists, nn, search_params );

                return 0;
            }
            catch (std::runtime_error& e) {
                Logger::error("Caught exception: %s\n",e.what());
                return -1;
            }

            return -1;
        '''
        ).replace('{', '{{').replace('}', '}}')
        py_source = ut.codeblock(
            '''
            if self.__curindex is None:
                raise FLANNException(
                    'build_index(...) method not called first or current index deleted.')

            if qpts.dtype.type not in allowed_types:
                raise FLANNException('Cannot handle type: %s' % qpts.dtype)

            if self.__curindex_type != qpts.dtype.type:
                raise FLANNException('Index and query must have the same type')

            qpts = ensure_2d_array(qpts, default_flags)

            npts, dim = self.get_indexed_shape()

            if qpts.size == dim:
                qpts.reshape(1, dim)

            nqpts = qpts.shape[0]

            assert qpts.shape[1] == dim, 'data and query must have the same dims'
            assert npts >= num_neighbors, 'more neighbors than there are points'

            result = np.empty((nqpts, num_neighbors), dtype=index_type)
            if self.__curindex_type == np.float64:
                dists = np.empty((nqpts, num_neighbors), dtype=np.float64)
            else:
                dists = np.empty((nqpts, num_neighbors), dtype=np.float32)

            self.__flann_parameters.update(kwargs)

            flann.find_nearest_neighbors_index[
                self.__curindex_type](
                self.__curindex, qpts, nqpts, result, dists, num_neighbors,
                pointer(self.__flann_parameters))

            if num_neighbors == 1:
                return (result.reshape(nqpts), dists.reshape(nqpts))
            else:
                return (result, dists)
            '''
        )
        docstr = 'Searches for nearest neighbors using the index provided'
        return_doc = zero_success
        return_type = 'int'
        # optional_args = ['Distance d = Distance()']
        binding_argnames = ['index_ptr', 'testset', 'tcount', 'result_ids',
                            'dists', 'nn', 'flann_params', ]
        py_alias = 'nn_index'
        py_args = ['qpts', 'num_neighbors=1', '**kwargs']

    elif binding_name == 'find_nearest_neighbors':
        c_source = ut.codeblock(
            r'''
            typedef typename Distance::ElementType ElementType;
            typedef typename Distance::ResultType DistanceType;

            try {{
                init_flann_parameters(flann_params);
                if (index_ptr==NULL) {{
                    throw FLANNException("Invalid index");
                }}
                Index<Distance>* index = (Index<Distance>*)index_ptr;

                Matrix<int> m_indices(result_ids,tcount, nn);
                Matrix<DistanceType> m_dists(dists, tcount, nn);

                SearchParams search_params = create_search_params(flann_params);
                index->knnSearch(Matrix<ElementType>(testset, tcount, index->veclen()),
                                 m_indices,
                                 m_dists, nn, search_params );

                return 0;
            }}
            catch (std::runtime_error& e) {{
                Logger::error("Caught exception: %s\n",e.what());
                return -1;
            }}

            return -1;
            '''
        )
        py_source = ut.codeblock(
            '''
            if pts.dtype.type not in allowed_types:
                raise FLANNException('Cannot handle type: %s' % pts.dtype)

            if qpts.dtype.type not in allowed_types:
                raise FLANNException('Cannot handle type: %s' % pts.dtype)

            if pts.dtype != qpts.dtype:
                raise FLANNException('Data and query must have the same type')

            pts = ensure_2d_array(pts, default_flags)
            qpts = ensure_2d_array(qpts, default_flags)

            npts, dim = pts.shape
            nqpts = qpts.shape[0]

            assert qpts.shape[1] == dim, 'data and query must have the same dims'
            assert npts >= num_neighbors, 'more neighbors than there are points'

            result = np.empty((nqpts, num_neighbors), dtype=index_type)
            if pts.dtype == np.float64:
                dists = np.empty((nqpts, num_neighbors), dtype=np.float64)
            else:
                dists = np.empty((nqpts, num_neighbors), dtype=np.float32)

            self.__flann_parameters.update(kwargs)

            flann.find_nearest_neighbors[
                pts.dtype.type](
                pts, npts, dim, qpts, nqpts, result, dists, num_neighbors,
                pointer(self.__flann_parameters))

            if num_neighbors == 1:
                return (result.reshape(nqpts), dists.reshape(nqpts))
            else:
                return (result, dists)
            ''')
        docstr = 'Builds an index and uses it to find nearest neighbors.'
        return_doc = zero_success
        py_alias = 'nn'
        py_args = ['pts', 'qpts', 'num_neighbors=1', '**kwargs']
        return_type = 'int'
        binding_argnames = ['dataset', 'rows', 'cols', 'testset', 'tcount',
                            'result_ids', 'dists', 'nn', 'flann_params']
        optional_args = ['Distance d = Distance()']
    elif binding_name == 'load_index':
        c_source_part = ut.codeblock(
            r'''
            Index<Distance>* index = new Index<Distance>(Matrix<typename Distance::ElementType>(dataset,rows,cols), SavedIndexParams(filename), d);
            return index;
            '''
        )
        py_source = ut.codeblock(
            '''
            if pts.dtype.type not in allowed_types:
                raise FLANNException('Cannot handle type: %s' % pts.dtype)

            pts = ensure_2d_array(pts, default_flags)
            npts, dim = pts.shape

            if self.__curindex is not None:
                flann.free_index[self.__curindex_type](
                    self.__curindex, pointer(self.__flann_parameters))
                self.__curindex = None
                self.__curindex_data = None
                self.__added_data = []
                self.__curindex_type = None

            self.__curindex = flann.load_index[pts.dtype.type](
                c_char_p(to_bytes(filename)), pts, npts, dim)

            if self.__curindex is None:
                raise FLANNException(
                    ('Error loading the FLANN index with filename=%r.'
                     ' C++ may have thrown more detailed errors') % (filename,))

            self.__curindex_data = pts
            self.__added_data = []
            self.__removed_ids = []
            self.__curindex_type = pts.dtype.type
            ''')
        docstr = 'Loads a previously saved index from a file.'
        return_doc = 'index_ptr'
        cpp_param_doc['dataset'] = 'The dataset corresponding to the index'
        cpp_param_doc['filename'] = 'File to load the index from'
        py_args = ['filename', 'pts']
        return_type = 'flann_index_t'
        binding_argnames = ['filename', 'dataset', 'rows', 'cols']
        optional_args = ['Distance d = Distance()']

    elif binding_name == 'save_index':
        docstr = 'Saves the index to a file. Only the index is saved into the file, the dataset corresponding to the index is not saved.'
        cpp_param_doc['index_ptr'] = 'The index that should be saved'
        cpp_param_doc['filename'] = 'The filename the index should be saved to'
        return_doc = 'Returns 0 on success, negative value on error'
        c_source_part = ut.codeblock(
            r'''
            Index<Distance>* index = (Index<Distance>*)index_ptr;
            index->save(filename);

            return 0;
            ''')
        py_source = ut.codeblock(
            '''
            if self.__curindex is not None:
                flann.save_index[self.__curindex_type](
                    self.__curindex, c_char_p(to_bytes(filename)))
            ''')
        return_type = 'int'
        binding_argnames = ['index_ptr', 'filename']
        py_alias = None
        py_args = None

    elif binding_name == 'build_index':
        docstr = ut.codeblock(
            '''
            Builds and returns an index. It uses autotuning if the target_precision field of index_params
            is between 0 and 1, or the parameters specified if it's -1.
            ''')
        pydoc = ut.codeblock(
            '''
            This builds and internally stores an index to be used for
            future nearest neighbor matchings.  It erases any previously
            stored indexes, so use multiple instances of this class to
            work with multiple stored indices.  Use nn_index(...) to find
            the nearest neighbors in this index.

            pts is a 2d numpy array or matrix. All the computation is done
            in np.float32 type, but pts may be any type that is convertable
            to np.float32.
            ''')
        c_source = ut.codeblock(
            r'''
            typedef typename Distance::ElementType ElementType;
            try {
                init_flann_parameters(flann_params);
                if (flann_params == NULL) {
                    throw FLANNException("The flann_params argument must be non-null");
                }
                IndexParams params = create_parameters(flann_params);
                Index<Distance>* index = new Index<Distance>(Matrix<ElementType>(dataset,rows,cols), params, d);
                index->buildIndex();

                if (flann_params->algorithm==FLANN_INDEX_AUTOTUNED) {
                    IndexParams params = index->getParameters();
                    update_flann_parameters(params,flann_params);
                    SearchParams search_params = get_param<SearchParams>(params,"search_params");
                    *speedup = get_param<float>(params,"speedup");
                    flann_params->checks = search_params.checks;
                    flann_params->eps = search_params.eps;
                    flann_params->cb_index = get_param<float>(params,"cb_index",0.0);
                }

                return index;
            }
            catch (std::runtime_error& e) {
                Logger::error("Caught exception: %s\n",e.what());
                return NULL;
            }
           ''').replace('{', '{{').replace('}', '}}')
        py_source = ut.codeblock(
            '''
            if pts.dtype.type not in allowed_types:
                raise FLANNException('Cannot handle type: %s' % pts.dtype)

            pts = ensure_2d_array(pts, default_flags)
            npts, dim = pts.shape

            self.__ensureRandomSeed(kwargs)

            self.__flann_parameters.update(kwargs)

            if self.__curindex is not None:
                flann.free_index[self.__curindex_type](
                    self.__curindex, pointer(self.__flann_parameters))
                self.__curindex = None

            speedup = c_float(0)
            self.__curindex = flann.build_index[pts.dtype.type](
                pts, npts, dim, byref(speedup), pointer(self.__flann_parameters))
            self.__curindex_data = pts
            self.__curindex_type = pts.dtype.type

            params = dict(self.__flann_parameters)
            params['speedup'] = speedup.value

            return params
            ''')
        # binding_argnames = ['dataset', 'rows', 'cols', 'speedup', 'flann_params']
        return_doc = 'the newly created index or a number <0 for error'
        cpp_param_doc['speedup'] = 'speedup over linear search, estimated if using autotuning, output parameter'
        optional_args = ['Distance d = Distance()']
        return_type = 'flann_index_t'
        py_args = ['pts', '**kwargs']
        binding_argnames = ['dataset', 'rows', 'cols', 'speedup', 'flann_params']
    elif binding_name == 'free_index':
        docstr = 'Deletes an index and releases the memory used by it.'
        pydoc = ut.codeblock(
            '''
            Deletes the current index freeing all the momory it uses.
            The memory used by the dataset that was indexed is not freed
            unless there are no other references to those numpy arrays.
            ''')
        c_source_part = ut.codeblock(
            r'''
            Index<Distance>* index = (Index<Distance>*)index_ptr;
            delete index;

            return 0;
            ''')
        py_source = ut.codeblock(
            '''
            self.__flann_parameters.update(kwargs)

            if self.__curindex is not None:
                flann.free_index[self.__curindex_type](
                    self.__curindex, pointer(self.__flann_parameters))
                self.__curindex = None
                self.__curindex_data = None
                self.__added_data = []
                self.__removed_ids = []
            ''')
        return_doc = zero_success
        return_type = 'int'
        binding_argnames = ['index_ptr', 'flann_params']
        cpp_param_doc['flann_params'] = ut.textblock(
            '''generic flann params (only used to specify verbosity)''')
        py_alias = 'delete_index'
        py_args = ['**kwargs']
    elif binding_name == 'get_point':
        docstr = 'Gets a point from a given index position.'
        return_doc = 'pointer to datapoint or NULL on miss'
        binding_argnames = ['index_ptr', 'point_id']
        cpp_param_doc['point_id'] = 'index of datapoint to get.'
        return_type = 'Distance::ElementType*'
    elif binding_name == 'flann_get_distance_order':
        docstr = ut.textblock(
            '''Gets the distance order in use throughout FLANN (only applicable
            if minkowski distance is in use).''')
        binding_argnames = []
        return_type = 'int'
    else:
        dictdef = {
            '_template_new': {
                'docstr': '',
                'binding_argnames': [],
                'return_type': 'int',
            },

            'flann_get_distance_type': {
                'docstr': '',
                'binding_argnames': [],
                'return_type': 'int',
            },

            'flann_log_verbosity': {
                'docstr': ut.codeblock(
                    '''
                     Sets the log level used for all flann functions (unless
                     specified in FLANNParameters for each call
                    '''
                ),
                'binding_argnames': ['level'],
                'return_type': 'void',
            },
        }
        if binding_name in dictdef:
            docstr = dictdef[binding_name].get('docstr', '')
            binding_argnames = dictdef[binding_name]['binding_argnames']
            return_type = dictdef[binding_name]['return_type']
        else:
            raise NotImplementedError('Unknown binding name %r' % (binding_name,))

    if c_source is None:
        if c_source_part is not None:
            try_ = ut.codeblock(
                '''
                try {{
                '''
            )
            throw_ = '\n' + ut.indent(ut.codeblock(
                '''
                    if (index_ptr==NULL) {{
                        throw FLANNException("Invalid index");
                    }}
                '''
            ), ' ' * 4)
            if 'index_ptr' not in binding_argnames:
                throw_ = ''
            if 'flann_params' in binding_argnames:
                part1 = try_ + '\n' + '    init_flann_parameters(flann_params);' + throw_
            else:
                part1 = try_ + throw_
            if return_type == 'int':
                default_return = '-1'
            else:
                default_return = 'NULL'
            part2 = ut.codeblock(
                r'''
                }}
                catch (std::runtime_error& e) {{
                    Logger::error("Caught exception: %s\n",e.what());
                    return ''' + default_return + ''';
                }}
            '''
            )
            c_source = part1 + '\n' +  ut.indent(c_source_part, ' ' * 4) + '\n' + part2
        else:
            c_source = ut.codeblock(
                '''
                TODO: IMPLEMENT THIS FUNCTION WRAPPER
                '''
            )

    try:
        docstr_cpp = docstr[:]

        if return_doc is not None:
            param_docs = ut.dict_take(cpp_param_doc, binding_argnames)
            cpp_param_docblock = '\n'.join(
                ['%s = %s' % (name, doc)
                 for name, doc in zip(binding_argnames, param_docs)])
            docstr_cpp += '\n\n' + 'Params:\n' + ut.indent(cpp_param_docblock, '    ')
            docstr_cpp += '\n\n' + 'Returns: ' + return_doc

        if pydoc is None:
            docstr_py = docstr[:]
        else:
            docstr_py = pydoc[:]

        if py_args:
            py_param_doc = cpp_param_doc.copy()
            py_param_doc['pts'] = py_param_doc['dataset'].replace('pointer to ', '')
            py_param_doc['qpts'] = (py_param_doc['testset'].replace(
                'pointer to ', '') + ' (may be a single point)')
            py_param_doc['num_neighbors'] = py_param_doc['nn']
            py_param_doc['**kwargs'] = py_param_doc['flann_params']
            py_args_ = [a.split('=')[0] for a in py_args]
            param_docs = ut.dict_take(py_param_doc, py_args_, '')
            # py_types =
            py_param_docblock = '\n'.join(['%s: %s' % (name, doc)
                                           for name, doc in zip(py_args_, param_docs)])
            docstr_py += '\n\n' + 'Params:\n' + ut.indent(py_param_docblock, '    ')
    except Exception as ex:
        ut.printex(ex, keys=['binding_name'])
        raise
        pass

    binding_def = {
        'cpp_binding_name': cpp_binding_name,
        'docstr_cpp': docstr_cpp,
        'docstr_py': docstr_py,
        'return_type': return_type,
        'binding_argnames': binding_argnames,
        'c_source': c_source,
        'optional_args': optional_args,
        'py_source': py_source,
        'py_args': py_args,
        'py_alias': py_alias,
    }

    return binding_def
