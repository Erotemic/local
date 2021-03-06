# -*- coding: utf-8 -*-
from __future__ import absolute_import, division, print_function, unicode_literals
import utool as ut
import sys
(print, rrr, profile) = ut.inject2(__name__, '[ibs]')

sys.path.append(ut.truepath('~/local/build_scripts/flannscripts'))

from flann_defs import define_flann_bindings  # NOQA


@profile
def update_bindings():
    r"""
    Returns:
        dict: matchtups

    CommandLine:
        python ~/local/build_scripts/flannscripts/autogen_bindings.py --exec-update_bindings
        utprof.py ~/local/build_scripts/flannscripts/autogen_bindings.py --exec-update_bindings

    Example:
        >>> # DISABLE_DOCTEST
        >>> from autogen_bindings import *  # NOQA
        >>> import sys
        >>> import utool as ut
        >>> sys.path.append(ut.truepath('~/local/build_scripts/flannscripts'))
        >>> matchtups = update_bindings()
        >>> result = ('matchtups = %s' % (ut.repr2(matchtups),))
        >>> print(result)
        >>> ut.quit_if_noshow()
        >>> import plottool as pt
        >>> ut.show_if_requested()
    """
    from os.path import basename
    import difflib
    import numpy as np
    import re
    binding_names = [
        'build_index',
        'used_memory',
        'add_points',
        'remove_point',

        'compute_cluster_centers',
        'load_index',
        'save_index',
        'find_nearest_neighbors',

        'radius_search',
        'remove_points',
        'free_index',
        'find_nearest_neighbors_index',

        # 'size',
        # 'veclen',
        # 'get_point',
        # 'flann_get_distance_order',
        # 'flann_get_distance_type',
        # 'flann_log_verbosity',

        # 'clean_removed_points',
    ]

    _places = [
        '~/code/flann/src/cpp/flann/flann.cpp',
        '~/code/flann/src/cpp/flann/flann.h',
        '~/code/flann/src/python/pyflann/flann_ctypes.py',
        '~/code/flann/src/python/pyflann/index.py',
    ]

    eof_sentinals = {
        # 'flann_ctypes.py': '# END DEFINE BINDINGS',
        'flann_ctypes.py': 'def ensure_2d_array(arr',
        # 'flann.h': '// END DEFINE BINDINGS',
        'flann.h': '#ifdef __cplusplus',
        'flann.cpp': None,
        'index.py': None,
    }
    block_sentinals = {
        'flann.h': re.escape('/**'),
        'flann.cpp': 'template *<typename Distance>',
        # 'flann_ctypes.py': '\n',
        'flann_ctypes.py': 'flann\.[a-z_.]* =',
        # 'index.py': '    def .*',
        'index.py': '    [^ ].*',
    }
    places = {basename(fpath): fpath for fpath in ut.lmap(ut.truepath, _places)}
    text_dict = ut.map_dict_vals(ut.readfrom, places)
    lines_dict = {key: val.split('\n') for key, val in text_dict.items()}
    orig_texts = text_dict.copy()  # NOQA
    binding_defs = {}
    named_blocks  = {}

    print('binding_names = %r' % (binding_names,))
    for binding_name in binding_names:
        blocks, defs = autogen_parts(binding_name)
        binding_defs[binding_name] = defs
        named_blocks[binding_name] = blocks

    for binding_name in ut.ProgIter(binding_names):
        ut.colorprint('+--- GENERATE BINDING %s -----' % (binding_name,), 'yellow')
        blocks_dict = named_blocks[binding_name]
        for key in places.keys():
            ut.colorprint('---- generating %s for %s -----' % (binding_name, key,), 'yellow')
            # key = 'flann_ctypes.py'
            # print(text_dict[key])
            old_text = text_dict[key]
            line_list = lines_dict[key]
            #text = old_text
            block = blocks_dict[key]

            debug = ut.get_argflag('--debug')
            # debug = True
            # if debug:
            #     print(ut.highlight_code(block, splitext(key)[1]))

            # Find a place in the code that already exists

            searchblock = block
            if key.endswith('.cpp') or key.endswith('.h'):
                searchblock = re.sub(ut.REGEX_C_COMMENT, '', searchblock,
                                     flags=re.MULTILINE | re.DOTALL)
            searchblock = '\n'.join(searchblock.splitlines()[0:3])

            # @ut.cached_func(verbose=False)
            def cached_match(old_text, searchblock):
                def isjunk(x):
                    return False
                    return x in ' \t,*()'
                def isjunk2(x):
                    return x in ' \t,*()'
                # Not sure why the first one just doesnt find it
                # isjunk = None
                sm = difflib.SequenceMatcher(isjunk, old_text, searchblock,
                                             autojunk=False)
                sm0 = difflib.SequenceMatcher(isjunk, old_text, searchblock,
                                              autojunk=True)
                sm1 = difflib.SequenceMatcher(isjunk2, old_text, searchblock,
                                              autojunk=False)
                sm2 = difflib.SequenceMatcher(isjunk2, old_text, searchblock,
                                              autojunk=True)
                matchtups = (sm.get_matching_blocks() +
                             sm0.get_matching_blocks() +
                             sm1.get_matching_blocks() +
                             sm2.get_matching_blocks())
                return matchtups
            matchtups = cached_match(old_text, searchblock)
            # Find a reasonable match in matchtups

            found = False
            if debug:
                # print('searchblock =\n%s' % (searchblock,))
                print('searchblock = %r' % (searchblock,))
            for (a, b, size) in matchtups:
                matchtext = old_text[a: a + size]
                pybind = binding_defs[binding_name]['py_binding_name']
                if re.search(binding_name + '\\b', matchtext) or re.search(pybind + '\\b', matchtext):
                    found = True
                    pos = a + size
                    if debug:
                        print('MATCHING TEXT')
                        print(matchtext)
                    break
                else:
                    if debug and 0:
                        print('Not matching')
                        print('matchtext = %r' % (matchtext,))
                        matchtext2 = old_text[a - 10: a + size + 20]
                        print('matchtext2 = %r' % (matchtext2,))

            if found:
                linelens = np.array(ut.lmap(len, line_list)) + 1
                sumlen = np.cumsum(linelens)
                row = np.where(sumlen < pos)[0][-1] + 1
                #print(line_list[row])
                # Search for extents of the block to overwrite
                block_sentinal = block_sentinals[key]
                row1 = ut.find_block_end(row, line_list, block_sentinal, -1) - 1
                row2 = ut.find_block_end(row + 1, line_list, block_sentinal, +1)
                eof_sentinal = eof_sentinals[key]
                if eof_sentinal is not None:
                    print('eof_sentinal = %r' % (eof_sentinal,))
                    row2 = min([count for count, line in enumerate(line_list) if line.startswith(eof_sentinal)][-1], row2)
                nr = len((block + '\n\n').splitlines())
                new_line_list = ut.insert_block_between_lines(
                    block + '\n', row1, row2, line_list)
                rtext1 = '\n'.join(line_list[row1:row2])
                rtext2 = '\n'.join(new_line_list[row1:row1 + nr])
                if debug:
                    print('-----')
                    ut.colorprint('FOUND AND REPLACING %s' % (binding_name,), 'yellow')
                    print(ut.highlight_code(rtext1))
                if debug:
                    print('-----')
                    ut.colorprint('FOUND AND REPLACED WITH %s' % (binding_name,), 'yellow')
                    print(ut.highlight_code(rtext2))
                if not ut.get_argflag('--diff') and not debug:
                    print(ut.color_diff_text(ut.difftext(rtext1, rtext2, num_context_lines=7, ignore_whitespace=True)))
            else:
                # Append to end of the file
                eof_sentinal = eof_sentinals[key]
                if eof_sentinal is None:
                    row2 = len(line_list) - 1
                else:
                    row2_choice = [count for count, line in enumerate(line_list)
                                   if line.startswith(eof_sentinal)]
                    if len(row2_choice) == 0:
                        row2 = len(line_list) - 1
                        assert False
                    else:
                        row2 = row2_choice[-1] - 1

                # row1 = row2 - 1
                # row2 = row2 - 1
                row1 = row2

                new_line_list = ut.insert_block_between_lines(
                    block + '\n', row1, row2, line_list)
                # block + '\n\n\n', row1, row2, line_list)

                rtext1 = '\n'.join(line_list[row1:row2])
                nr = len((block + '\n\n').splitlines())
                rtext2 = '\n'.join(new_line_list[row1:row1 + nr])

                if debug:
                    print('-----')
                    ut.colorprint('NOT FOUND AND REPLACING %s' % (binding_name,), 'yellow')
                    print(ut.highlight_code(rtext1))
                if debug:
                    print('-----')
                    ut.colorprint('NOT FOUND AND REPLACED WITH %s' % (binding_name,), 'yellow')
                    print(ut.highlight_code(rtext2))

                if not ut.get_argflag('--diff') and not debug:
                    print(ut.color_diff_text(ut.difftext(rtext1, rtext2, num_context_lines=7, ignore_whitespace=True)))
            text_dict[key] = '\n'.join(new_line_list)
            lines_dict[key] = new_line_list
        ut.colorprint('L___  GENERATED BINDING %s ___' % (binding_name,), 'yellow')

    for key in places:
        new_text = '\n'.join(lines_dict[key])
        #ut.writeto(ut.augpath(places[key], '.new'), new_text)
        ut.writeto(ut.augpath(places[key]), new_text)

    for key in places:
        if ut.get_argflag('--diff'):
            difftext = ut.get_textdiff(orig_texts[key], new_text,
                                       num_context_lines=7, ignore_whitespace=True)
            difftext = ut.color_diff_text(difftext)
            print(difftext)


def autogen_parts(binding_name=None):
    r"""
    CommandLine:
        python ~/local/build_scripts/flannscripts/autogen_bindings.py --exec-autogen_parts
        python ~/local/build_scripts/flannscripts/autogen_bindings.py --exec-autogen_parts --bindingname=set_dataset
        python ~/local/build_scripts/flannscripts/autogen_bindings.py --exec-autogen_parts --bindingname=add_points
        python ~/local/build_scripts/flannscripts/autogen_bindings.py --exec-autogen_parts --bindingname=remove_point --py
        python ~/local/build_scripts/flannscripts/autogen_bindings.py --exec-autogen_parts --bindingname=used_memory  --py
        python ~/local/build_scripts/flannscripts/autogen_bindings.py --exec-autogen_parts --bindingname=remove_points  --py --c

        python ~/local/build_scripts/flannscripts/autogen_bindings.py --exec-autogen_parts --bindingname=veclen  --py --c

        python ~/local/build_scripts/flannscripts/autogen_bindings.py --exec-autogen_parts --bindingname=size  --py --c
        python ~/local/build_scripts/flannscripts/autogen_bindings.py --exec-autogen_parts --bindingname=clean_removed_points  --py --c

    Ignore:
        # Logic goes here
        ~/code/flann/src/cpp/flann/algorithms/kdtree_index.h
        ~/code/flann/src/cpp/flann/util/serialization.h
        ~/code/flann/src/cpp/flann/util/dynamic_bitset.h

        # Bindings go here
        ~/code/flann/src/cpp/flann/flann.cpp
        ~/code/flann/src/cpp/flann/flann.h

        # Contains stuff for the flann namespace like flann::log_level
        # Also has Index with
        # Matrix<ElementType> features; SEEMS USEFUL
        ~/code/flann/src/cpp/flann/flann.hpp


        # Wrappers go here
        ~/code/flann/src/python/pyflann/flann_ctypes.py
        ~/code/flann/src/python/pyflann/index.py

        ~/local/build_scripts/flannscripts/autogen_bindings.py

    Example:
        >>> # ENABLE_DOCTEST
        >>> from autogen_bindings import *  # NOQA
        >>> result = autogen_parts()
        >>> print(result)
    """
    #ut.get_dynlib_exports(pyflann.flannlib._name)
    #flannlib

    if binding_name is None:
        binding_name = ut.get_argval('--bindingname', type_=str, default='add_points')

    # Variable names used in flann cpp source

    simple_c_to_ctypes = {
        'void'                            : None,
        'char*'                           : 'c_char_p',
        'unsigned int'                    : 'c_uint',
        'int'                             : 'c_int',
        'float'                           : 'c_float',
        'float*'                          : 'POINTER(c_float)',
        'flann_index_t'                   : 'FLANN_INDEX',
        'FLANNParameters*'                : 'POINTER(FLANNParameters)',
        'Distance::ResultType*'           : "ndpointer(%(restype)s, flags='aligned, c_contiguous, writeable')",
        'Distance::ElementType*'          : "ndpointer(%(numpy)s, ndim=2, flags='aligned, c_contiguous')",
        'typename Distance::ElementType*' : "ndpointer(%(numpy)s, ndim=2, flags='aligned, c_contiguous')",
        'typename Distance::ResultType*'  : "ndpointer(%(restype), ndim=2, flags='aligned, c_contiguous, writeable')",
    }

    templated_ctype_map = {
        'filename'          : 'char*',
        'level'             : 'int',
        'rows'              : 'int',
        'cols'              : 'int',
        'point_id'          : 'unsigned int',
        'num'               : 'int',
        'max_nn'            : 'int',
        'tcount'            : 'int',
        'nn'                : 'int',
        'radius'            : 'float',
        'clusters'          : 'int',
        'rebuild_threshold' : 'float',
        'index_ptr'         : 'flann_index_t',
        'flann_params'      : 'FLANNParameters*',
        'speedup'           : 'float*',
        'id_list'           : 'int*',
        #'indices'           : 'int*',
        'dataset'           : 'typename Distance::ElementType*',
        'points'            : 'typename Distance::ElementType*',
        'query'             : 'typename Distance::ElementType*',
        'query1d'           : 'typename Distance::ElementType*',
        'testset'           : 'typename Distance::ElementType*',
        'dists'             : 'typename Distance::ResultType*',
        'dists1d'           : 'typename Distance::ResultType*',
        'result_centers'    : 'typename Distance::ResultType*',
        'result_ids'        : 'int*',
    }

    # Python ctype bindings
    python_ctype_map = {
        'flann_params' : 'POINTER(FLANNParameters)',
        'id_list'      : "ndpointer(int32, ndim=1, flags='aligned, c_contiguous')",
        #'indices'      : "ndpointer(int32, ndim=1, flags='aligned, c_contiguous, writeable')",
        'query1d'      : "ndpointer(%(numpy)s, ndim=1, flags='aligned, c_contiguous')",
        'dists1d'      : "ndpointer(%(restype), ndim=1, flags='aligned, c_contiguous, writeable')",
        'result_ids'   : "ndpointer(int32, ndim=2, flags='aligned, c_contiguous, writeable')",
        #'query'       : "ndpointer(float64, ndim=1, flags='aligned, c_contiguous')",
    }

    for key, val in templated_ctype_map.items():
        if key not in python_ctype_map:
            python_ctype_map[key] = simple_c_to_ctypes[val]

    binding_def = define_flann_bindings(binding_name)
    docstr_cpp       = binding_def['docstr_cpp']
    docstr_py       = binding_def['docstr_py']
    cpp_binding_name = binding_def['cpp_binding_name']
    return_type      = binding_def['return_type']
    binding_argnames = binding_def['binding_argnames']
    c_source         = binding_def['c_source']
    py_source        = binding_def['py_source']
    optional_args    = binding_def['optional_args']
    py_alias         = binding_def['py_alias']
    py_args          = binding_def['py_args']

    binding_args = [python_ctype_map[name] + ',  # ' + name for name in binding_argnames]
    binding_args_str = '        ' + '\n        '.join(binding_args)
    callargs = ', '.join(binding_argnames)
    pycallargs = ', '.join([name for name in ['self'] + binding_argnames if name != 'index_ptr'])

    if py_args is None:
        py_args = binding_argnames
        pyinputargs = pycallargs  # FIXME
    else:
        pyinputargs = ', '.join(['self'] + py_args)

    pyrestype = simple_c_to_ctypes[return_type]

    if py_alias is None:
        py_binding_name = binding_name
    else:
        py_binding_name = py_alias

    binding_def['py_binding_name'] = py_binding_name

    #### flann_ctypes.py

    flann_ctypes_codeblock = ut.codeblock(
        '''
        flann.{binding_name} = {{}}
        define_functions(r"""
        flannlib.flann_{binding_name}_%(C)s.restype = {pyrestype}
        flannlib.flann_{binding_name}_%(C)s.argtypes = [
        {binding_args_str}
        ]
        flann.{binding_name}[%(numpy)s] = flannlib.flann_{binding_name}_%(C)s
        """)
        '''
    ).format(binding_name=binding_name, binding_args_str=binding_args_str, pyrestype=pyrestype)

    #### index.py
    default_py_source_parts = []
    if 'pts' in py_args:
        default_py_source_parts.append(ut.codeblock(
            '''
            if pts.dtype.type not in allowed_types:
                raise FLANNException('Cannot handle type: %s' % pts.dtype)
            pts = ensure_2d_array(pts, default_flags)
            '''))

    default_py_source_parts.append(ut.codeblock(
        '''
        rows = pts.shape[0]
        raise NotImplementedError('requires custom implementation')
        flann.{binding_name}[self.__curindex_type](self.__curindex, {pycallargs})
        '''
    ))

    if py_source is None:
        py_source = '\n'.join(default_py_source_parts)

    flann_index_codeblock = ut.codeblock(
        r'''
        def {py_binding_name}({pyinputargs}):
            """''' + ut.indent('\n' + docstr_py, '            ') + '''
            """''' + '\n' + ut.indent(py_source, '            ') + '''
        '''
    ).format(binding_name=binding_name, pycallargs=pycallargs,
             py_binding_name=py_binding_name,
             pyinputargs=pyinputargs, py_source=py_source)

    #### flann.cpp
    #// {binding_name} BEGIN CPP BINDING
    #template <typename Distance>
    #{return_type} __flann_{binding_name}({templated_args})
    flann_cpp_code_fmtstr_ = ut.codeblock(
        r'''
        {{''' + '\n' + ut.indent(c_source, ' ' * (4 * 3)) + r'''
        }}
        '''
    )

    #implicit_type_bindings_fmtstr = ut.codeblock(  # NOQA
    #    '''
    #    DISTANCE_TYPE_BINDINGS({return_type}, {binding_name},
    #            SINGLE_ARG({T_typed_sigargs_cpp}),
    #            SINGLE_ARG({callargs}))

    #    '''
    #)
    #type_bindings_fmtstr = implicit_type_bindings_fmtstr

    explicit_type_bindings_part3_fmtstr = ut.codeblock(
        r'''
        {{
            if (flann_distance_type==FLANN_DIST_EUCLIDEAN) {{
                return __flann_{binding_name}<L2<T> >({callargs});
            }}
            else if (flann_distance_type==FLANN_DIST_MANHATTAN) {{
                return __flann_{binding_name}<L1<T> >({callargs});
            }}
            else if (flann_distance_type==FLANN_DIST_MINKOWSKI) {{
                return __flann_{binding_name}<MinkowskiDistance<T> >({callargs}{minkowski_option});
            }}
            else if (flann_distance_type==FLANN_DIST_HIST_INTERSECT) {{
                return __flann_{binding_name}<HistIntersectionDistance<T> >({callargs});
            }}
            else if (flann_distance_type==FLANN_DIST_HELLINGER) {{
                return __flann_{binding_name}<HellingerDistance<T> >({callargs});
            }}
            else if (flann_distance_type==FLANN_DIST_CHI_SQUARE) {{
                return __flann_{binding_name}<ChiSquareDistance<T> >({callargs});
            }}
            else if (flann_distance_type==FLANN_DIST_KULLBACK_LEIBLER) {{
                return __flann_{binding_name}<KL_Divergence<T> >({callargs});
            }}
            else {{
                Logger::error( "Distance type unsupported in the C bindings, use the C++ bindings instead\n");
                {errorhandle}
            }}
        }}
        '''
    )

    # c binding body
    c_bodyblock_fmtstr = ut.codeblock(
        '''
        {return_type} flann_{binding_name}{signame_type}({T_typed_sigargs2})
        {{
            {ifreturns}_flann_{binding_name}{iftemplate}({callargs});
        }}
        '''
    )

    #### flann.h

    # c binding header
    #c_headersig_fmtstr = 'FLANN_EXPORT {return_type} flann_{binding_name}{signame_type}({T_typed_sigargs2});'
    c_headersig_part1_fmtstr = 'FLANN_EXPORT {return_type} flann_{binding_name}{signame_type}('

    #### format cpp parts

    binding_argtypes = ut.dict_take(templated_ctype_map, binding_argnames)

    _fix_T = {
        'typename Distance::ElementType*': 'T*',
        'typename Distance::ResultType*': 'R*',
    }
    templated_ctype_map_cpp = {name: _fix_T.get(type_, type_) for name, type_ in templated_ctype_map.items()}
    binding_argtypes_cpp = ut.dict_take(templated_ctype_map_cpp, binding_argnames)
    binding_sigargs_cpp = [type_ + ' ' + name
                           for type_, name in zip(binding_argtypes_cpp, binding_argnames)]
    templated_bindings = [templated_ctype_map[name] + ' ' + name for name in binding_argnames]
    if optional_args is not None:
        templated_bindings += optional_args
        minkowski_option = ', MinkowskiDistance<T>(flann_distance_order)'
    else:
        minkowski_option = ''

    templated_args = ', '.join(templated_bindings)
    if binding_name == 'remove_point':
        # HACK
        templated_args += '_uint'
    cpp_sig_part1 = '{return_type} __flann_{binding_name}('.format(return_type=return_type, binding_name=binding_name)
    maxlen = 100
    cpp_sig_ = ut.packstr(cpp_sig_part1 + templated_args, textwidth=maxlen, breakchars=', ', wordsep=', ', break_words=False, newline_prefix=' ' * len(cpp_sig_part1))
    cpp_sig = cpp_sig_[:-2] + ')'
    flann_cpp_code_fmtstr = 'template <typename Distance>\n' + cpp_sig + '\n' + flann_cpp_code_fmtstr_
    #print(cpp_sig)

    T_typed_sigargs_cpp = ', '.join(binding_sigargs_cpp)

    used_template_list = []
    used_template_list.append('typename T')
    if 'typename Distance::ResultType*' in binding_argtypes:
        used_template_list.append('typename R')
    used_templates = ', '.join(used_template_list)

    type_binding_part1 = 'template <{used_templates}>'.format(used_templates=used_templates)
    type_binding_part2_ = '{return_type} _flann_{binding_name}('.format(return_type=return_type, binding_name=binding_name)

    maxlen = 100
    cpp_type_sig_ = ut.packstr(type_binding_part2_ + T_typed_sigargs_cpp, textwidth=maxlen, breakchars=', ', wordsep=', ', break_words=False, newline_prefix=' ' * len(type_binding_part2_))
    cpp_type_sig = cpp_type_sig_[:-2] + ')'
    type_binding_part12 = type_binding_part1 + '\n' + cpp_type_sig

    explicit_type_bindings_fmtstr =  type_binding_part12 + '\n' + explicit_type_bindings_part3_fmtstr

    flann_cpp_codeblock_fmtstr = flann_cpp_code_fmtstr + '\n\n\n' + explicit_type_bindings_fmtstr + '\n'

    if return_type == 'int':
        errorhandle = 'return -1;'
    elif return_type == 'flann_index_t':
        errorhandle = 'return NULL;'
    else:
        errorhandle = 'throw 0;'

    # print('------')
    # print('flann_cpp_codeblock_fmtstr.format = %s' % (flann_cpp_codeblock_fmtstr,))
    try:
        flann_cpp_codeblock = flann_cpp_codeblock_fmtstr.format(
            cpp_binding_name=cpp_binding_name,
            minkowski_option=minkowski_option,
            binding_name=binding_name,
            #templated_args=templated_args,
            callargs=callargs,
            #T_typed_sigargs_cpp=T_typed_sigargs_cpp,
            errorhandle=errorhandle,
            used_templates=used_templates, return_type=return_type)
    except KeyError as ex:
        ut.printex(ex, keys=['binding_name'])
        raise

    dataset_types = [
        '',
        'float',
        'double',
        'byte',
        'int',
    ]

    #### format c parts
    c_header_sigs = []
    c_body_blocks = []
    templated_ctype_map_c = templated_ctype_map.copy()
    #templated_ctype_map_c['dataset'] = 'float'

    _fix_explicit_ctype = {
        ''     : 'float',
        'byte' : 'unsigned char',
    }

    # For each explicit c type
    for dataset_type in dataset_types:
        T_type = _fix_explicit_ctype.get(dataset_type, dataset_type)
        if dataset_type != '':
            signame_type = '_' + dataset_type
        else:
            signame_type = dataset_type
        R_type = 'float' if T_type != 'double' else 'double'
        dstype = T_type + '*'
        rstype = R_type + '*'
        # Overwrite template types with explicit c types
        needstemplate = True
        for type_, name in zip(binding_argtypes, binding_argnames):
            if type_ == 'typename Distance::ElementType*':
                templated_ctype_map_c[name] = dstype
                needstemplate = False
            if type_ == 'typename Distance::ResultType*':
                templated_ctype_map_c[name] = rstype
                needstemplate = False
            if type_ == 'Distance::ResultType*':
                templated_ctype_map_c[name] = rstype
                needstemplate = False
            #if type_ == 'struct FLANNParameters*':
            #    # hack
            #    templated_ctype_map_c[name] = 'FLANNParameters*'
        # HACK
        if binding_name == 'load_index' or binding_name == 'add_points':
            needstemplate = True
        if binding_name == 'build_index':
            needstemplate = True
        binding_argtypes2 = ut.dict_take(templated_ctype_map_c, binding_argnames)
        binding_sigargs2 = [type_ + ' ' + name for type_, name in
                            zip(binding_argtypes2, binding_argnames)]
        T_typed_sigargs2 = ', '.join(binding_sigargs2)
        T_typed_sigargs2_nl = ',\n'.join(binding_sigargs2)
        if needstemplate:
            iftemplate = '<{T_type}>'.format(T_type=T_type)
        else:
            iftemplate = ''
        if return_type != 'void':
            ifreturns = 'return '
        else:
            ifreturns = ''
        bodyblock = c_bodyblock_fmtstr.format(signame_type=signame_type,
                                              T_typed_sigargs2=T_typed_sigargs2,
                                              binding_name=binding_name,
                                              callargs=callargs,
                                              iftemplate=iftemplate,
                                              ifreturns=ifreturns,
                                              return_type=return_type)

        header_line_part1 = c_headersig_part1_fmtstr.format(signame_type=signame_type,
                                                            binding_name=binding_name,
                                                            return_type=return_type)
        header_line = header_line_part1 + ut.indent(T_typed_sigargs2_nl, ' ' * len(header_line_part1)).lstrip(' ') + ');'
        # Hack for header
        header_line = header_line.replace('FLANNParameters* flann_params', 'struct FLANNParameters* flann_params')

        #header_line = c_headersig_fmtstr.format(signame_type=signame_type,
        #                                        T_typed_sigargs2=T_typed_sigargs2,
        #                                        binding_name=binding_name,
        #                                        return_type=return_type)
        c_header_sigs.append(header_line)
        c_body_blocks.append(bodyblock)

    flann_cpp_codeblock += '\n' + '\n'.join(c_body_blocks)
    #flann_cpp_codeblock += '\n' + '// {binding_name} END'.format(binding_name=binding_name)

    #BEGIN {binding_name}
    flann_h_codeblock = ut.codeblock(
        r'''
        /**
        {docstr_cpp}
         */
        '''
    ).format(docstr_cpp=docstr_cpp, binding_name=binding_name)
    flann_h_codeblock += '\n\n' +  '\n\n'.join(c_header_sigs)

    blocks_dict = {}
    import re
    flann_index_codeblock = ut.indent(flann_index_codeblock, '    ')
    blocks_dict['flann_ctypes.py'] = flann_ctypes_codeblock
    blocks_dict['index.py'] = flann_index_codeblock
    blocks_dict['flann.h'] = flann_h_codeblock
    blocks_dict['flann.cpp'] = flann_cpp_codeblock

    for key in blocks_dict.keys():
        blocks_dict[key] = re.sub('\n\s+\n', '\n\n', blocks_dict[key])
        # , flags=re.MULTILINE)
        blocks_dict[key] = re.sub('\s\s+\n', '\n', blocks_dict[key])
        pass

    if ut.get_argflag('--py'):
        print('\n\n# ---------------\n\n')
        print('GOES IN flann_ctypes.py')
        print('\n\n# ---------------\n\n')
        print(flann_ctypes_codeblock)

        print('\n\n# ---------------\n\n')
        print('GOES IN index.py')
        print('\n\n# ---------------\n\n')
        print(flann_index_codeblock)

    if ut.get_argflag('--c'):
        print('\n\n# ---------------\n\n')
        print('GOES IN flann.h')
        print('\n\n# ---------------\n\n')
        print(flann_h_codeblock)

        print('\n\n# ---------------\n\n')
        print('GOES IN flann.cpp')
        print('\n\n# ---------------\n\n')
        print(flann_cpp_codeblock)
    return blocks_dict, binding_def

if __name__ == '__main__':
    """
    CommandLine:
        python ~/local/build_scripts/flannscripts/autogen_bindings.py
        python ~/local/build_scripts/flannscripts/autogen_bindings.py --allexamples
        python ~/local/build_scripts/flannscripts/autogen_bindings.py --allexamples --noface --nosrc
    """
    import multiprocessing
    multiprocessing.freeze_support()  # for win32
    import utool as ut  # NOQA
    ut.doctest_funcs()


"""
Notes:

    cpp/flann/algorithms/nn_index.h

    void cleanRemovedPoints()
    {
        // FIXME: was protected. Are we sure this is the right function?
        // I think the answer is no. Need to make function that reassigns ids
        // to a new dataset.  Only called from within this function
        Logger::debug("[NNIndex] cleanRemovedPoints()\n");
        Logger::debug("[NNIndex] * removed_ = %d\n", removed_);
        Logger::debug("[NNIndex] * removed_count_ = %d\n", removed_count_);
        if (!removed_) return;

        Logger::debug("[NNIndex] * size_ = %d\n", size_);

        size_t last_idx = 0;
        for (size_t i=0;i<size_;++i) {
            if (!removed_points_.test(i)) {
                points_[last_idx] = points_[i];
                ids_[last_idx] = ids_[i];
                removed_points_.reset(last_idx);
                ++last_idx;
            }
        }

        Logger::debug("[NNIndex] * last_idx = %d\n", last_idx);

        points_.resize(last_idx);
        ids_.resize(last_idx);
        removed_points_.resize(last_idx);
        size_ = last_idx;
        removed_count_ = 0;
        Logger::debug("[NNIndex] finished cleanRemovedPoints()\n");
    }

"""
