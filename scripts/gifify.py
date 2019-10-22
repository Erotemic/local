#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
A gif-ify script

Wrapper around imgmagik convert
"""

import ubelt as ub


def main():
    import argparse
    description = ub.codeblock(
        '''
        Convert a sequence of images into a gif
        ''')
    parser = argparse.ArgumentParser(prog='gifify', description=description)

    parser.add_argument('image_list', nargs='*', help='list of images')
    parser.add_argument('-i', '--input', nargs='*', help='alternate way to specify list of images')
    parser.add_argument('-d', '--delay', nargs=1, type=int, default=10, help='delay between frames')
    parser.add_argument('-o', '--output', default='out.gif', help='output file')
    args, unknown = parser.parse_known_args()
    # print('unknown = {!r}'.format(unknown))
    # print('args = {!r}'.format(args))
    ns = args.__dict__.copy()

    image_paths1 = ns['image_list']
    image_paths2 = ns['input']

    print('Converting:')
    print('image_paths1 = ' + ub.repr2(image_paths1))
    print('image_paths2 = ' + ub.repr2(image_paths2))

    if image_paths1:
        image_paths = image_paths1
        assert not image_paths2, 'can only specify inputs one way'
    elif image_paths2:
        image_paths = image_paths2
        assert not image_paths1, 'can only specify inputs one way'

    assert image_paths is not None

    frame_fpaths = []
    import glob
    from os.path import isdir, join
    for p in image_paths:
        if isdir(p):
            toadd = sorted(glob.glob(join(p, '*.png')))
            toadd += sorted(glob.glob(join(p, '*.jpg')))
            frame_fpaths.extend(toadd)
        else:
            frame_fpaths.append(p)

    print('frame_fpaths = {!r}'.format(frame_fpaths))

    backend = 'imagemagik'
    backend = 'ffmpeg'
    if backend == 'imagemagik':
        escaped_gif_fpath = ns['output'].replace('%', '%%')
        command = ['convert', '-delay', str(ns['delay']), '-loop', '0']
        command += frame_fpaths
        command += [escaped_gif_fpath]
        # print('command = {!r}'.format(command))
        print('Converting {} images to gif: {}'.format(len(frame_fpaths), escaped_gif_fpath))
        info = ub.cmd(command, verbose=3)
        print('finished')
        if info['ret'] != 0:
            print(info['out'])
            print(info['err'])
            raise RuntimeError(info['err'])
    elif backend == 'ffmpeg':
        output_fpath = ns['output']
        ffmpeg_animate_frames(frame_fpaths, output_fpath)
        pass

    return info['err']


def ffmpeg_animate_frames(frame_fpaths, output_fpath, in_framerate=1, verbose=1):
    """
    Use ffmpeg to transform a series of frames into a video.

    Args:
        frame_fpaths (List[PathLike]): ordered list of frames to be combined
            into an animation

        output_fpath (PathLike): output video name, as either a
            gif, avi, mp4, etc.

        in_framerate (int): number of input frames per second to use (lower is
            slower)

    Example:
        >>> import ndsampler
        >>> dset = ndsampler.CocoDataset.demo('shapes64')
        >>> frame_fpaths = sorted(dset.images().gpath)
        >>> test_dpath = ub.ensure_app_cache_dir('gifify', 'test')
        >>> # Test output to GIF
        >>> output_fpath = join(test_dpath, 'test.gif')
        >>> ffmpeg_animate_frames(frame_fpaths, output_fpath, in_framerate=0.5)
        >>> # Test number of frames is correct
        >>> from PIL import Image
        >>> pil_gif = Image.open(output_fpath)
        >>> try:
        >>>     while 1:
        >>>         pil_gif.seek(pil_gif.tell()+1)
        >>>         # do something to im
        >>> except EOFError:
        >>>     pass # end of sequence
        >>> assert pil_gif.tell() + 1 == 64
        >>> # Test output to video
        >>> output_fpath = join(test_dpath, 'test.mp4')
        >>> ffmpeg_animate_frames(frame_fpaths, output_fpath, in_framerate=10, verbose=1)
    """
    from os.path import join
    import uuid
    # import tempfile
    try:
        # temp_dpath = tempfile.mkdtemp()
        temp_dpath = ub.ensure_app_cache_dir('gifify', 'temp')
        temp_fpath = join(temp_dpath, 'temp_list_{}.txt'.format(str(uuid.uuid4())))
        lines = ["file '{}'".format(fpath) for fpath in frame_fpaths]
        text = '\n'.join(lines)
        with open(temp_fpath, 'w') as file:
            file.write(text + '\n')

        # https://stackoverflow.com/questions/20847674/ffmpeg-libx264-height-not-divisible-by-2
        # evan_pad_option = '-filter:v pad="width=ceil(iw/2)*2:height=ceil(ih/2)*2"'
        # vid_options = '-c:v libx264 -profile:v high -crf 20 -pix_fmt yuv420p'

        fmtkw = dict(
            IN=temp_fpath,
            OUT=output_fpath,
        )

        global_options = []
        input_options = [
            '-r {IN_FRAMERATE} ',
            '-f concat -safe 0',
            # '-framerate {IN_FRAMERATE} ',
        ]
        fmtkw.update(dict(
            IN_FRAMERATE=in_framerate,
        ))

        output_options = [
            # '-qscale 0',
            # '-crf 20',
            # '-r {OUT_FRAMERATE}',
            # '-filter:v scale=512:-1',
        ]
        fmtkw.update(dict(
            # OUT_FRAMERATE=5,
        ))

        if output_fpath.endswith('.mp4'):
            output_options += [
                # MP4 needs even width
                # https://stackoverflow.com/questions/20847674/ffmpeg-div2
                '-filter:v pad="width=ceil(iw/2)*2:height=ceil(ih/2)*2"',
            ]

        cmd_fmt = ' '.join(
            ['ffmpeg -y'] +
            global_options +
            input_options +
            ['-i {IN}'] +
            output_options +
            ['{OUT}']
        )

        command = cmd_fmt.format(**fmtkw)

        if verbose > 0:
            print('Converting {} images to animation: {}'.format(len(frame_fpaths), output_fpath))

        info = ub.cmd(command, verbose=3 if verbose > 1 else 0)

        if verbose > 0:
            print('finished')

    finally:
        ub.delete(temp_dpath)

    if info['ret'] != 0:
        # if not verbose:
        # print(info['out'])
        # print(info['err'])
        raise RuntimeError(info['err'])
    # -f concat -i mylist.txt
    #   ffmpeg \
    # -framerate 60 \
    # -pattern_type glob \
    # -i '*.png' \
    # -r 15 \
    # -vf scale=512:-1 \
    # out.gif \


if __name__ == '__main__':
    """
    CommandLine:
        6 -i "$(ls -tr batch)"
    """
    main()
