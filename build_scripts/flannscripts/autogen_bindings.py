
import utool as ut


def update_bindings():
    r"""
    CommandLine:
        python ~/local/build_scripts/flannscripts/autogen_bindings.py --exec-update_bindings

    Example:
        >>> # DISABLE_DOCTEST
        >>> import sys
        >>> import utool as ut
        >>> sys.path.append(ut.truepath('~/local/build_scripts/flannscripts'))
        >>> from autogen_bindings import *  # NOQA
        >>> result = update_bindings()
    """
    binding_names = [
        'used_memory',
        'add_points',
        'remove_point',
        'remove_points',
        'clean_removed_points',

        'compute_cluster_centers',
        'radius_search',
        'find_nearest_neighbors_index',
        'find_nearest_neighbors',
        'load_index',
        'save_index',
        'build_index',
        'free_index',
    ]

    _places = [
        '~/code/flann/src/cpp/flann/flann.cpp',
        '~/code/flann/src/cpp/flann/flann.h',
        '~/code/flann/src/python/pyflann/flann_ctypes.py',
        '~/code/flann/src/python/pyflann/index.py',
    ]

    sentinals = {
        # 'flann_ctypes.py': '# END DEFINE BINDINGS',
        'flann.h': '// END DEFINE BINDINGS',
    }
    from os.path import basename
    places = {basename(fpath): fpath for fpath in ut.lmap(ut.truepath, _places)}
    texts = ut.map_dict_vals(ut.readfrom, places)
    orig_texts = texts.copy()  # NOQA

    for binding_name in binding_names:
        blocks_dict = autogen_parts(binding_name)
        for key in sentinals.keys():
            # key = 'flann_ctypes.py'
            # print(texts[key])
            text = old_text = texts[key]
            sentinal = '\n' + sentinals[key] + ' *\n'
            block = blocks_dict[key]
            print(ut.msgblock(binding_name, block))
            blockid = block.split('\n')[0]

            blockpos = text.find(blockid)

            if blockpos == -1:
                print('sentinal = %r' % (sentinal,))
                new_text = ut.insert_before_sentinal(old_text, '\n' + block + '\n\n', sentinal)
            else:
                startpos = blockpos
                #def find_block_endpos(startpos):
                rel_endpos = text[startpos:].find('\n\n\n')
                assert rel_endpos != -1
                endpos = startpos + rel_endpos
                new_text = old_text[:startpos] + block + old_text[endpos:]
            texts[key] = new_text

        #print(ut.get_colored_diff(ut.get_textdiff(old_text, new_text, num_context_lines=5)))
    print(ut.get_colored_diff(ut.get_textdiff(orig_texts[key], texts[key], num_context_lines=100)))


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
        'void': None,
        'char*': 'c_char_p',
        'int': 'c_int',
        'float': 'c_float',
        'float*': 'POINTER(c_float)',
        'flann_index_t': 'FLANN_INDEX',
        'FLANNParameters*': 'POINTER(FLANNParameters)',
        'typename Distance::ElementType*': "ndpointer(%(numpy)s, ndim=2, flags='aligned, c_contiguous')",
        'Distance::ResultType*': "ndpointer(%(restype)s, flags='aligned, c_contiguous, writeable')",
        'typename Distance::ResultType*': "ndpointer(%(restype), ndim=2, flags='aligned, c_contiguous, writeable')",
    }

    INDEX_PTR_NAME = 'index_id'

    templated_ctype_map = {
        'filename'          : 'char*',
        'rows'              : 'int',
        'cols'              : 'int',
        'id_'               : 'int',
        'num'               : 'int',
        'max_nn'            : 'int',
        'tcount'            : 'int',
        'nn'            : 'int',
        'radius'            : 'float',
        'clusters'          : 'int',
        'rebuild_threshold' : 'int',
        INDEX_PTR_NAME      : 'flann_index_t',
        'flann_params'      : 'FLANNParameters*',
        'speedup'           : 'float*',
        'id_list'           : 'int*',
        'indices'           : 'int*',
        'dataset'           : 'typename Distance::ElementType*',
        'query'             : 'typename Distance::ElementType*',
        'query1d'           : 'typename Distance::ElementType*',
        'testset'           : 'typename Distance::ElementType*',
        'dists'             : 'typename Distance::ResultType*',
        'dists1d'           : 'typename Distance::ResultType*',
        'result_centers'    : 'Distance::ResultType*',
        'result_ids'        : 'int*',
    }

    # Python ctype bindings
    python_ctype_map = {
        'flann_params': 'POINTER(FLANNParameters)',
        'id_list' : "ndpointer(int32, ndim=1, flags='aligned, c_contiguous')",
        'indices' : "ndpointer(int32, ndim=1, flags='aligned, c_contiguous, writeable')",
        'query1d'   : "ndpointer(%(numpy)s, ndim=1, flags='aligned, c_contiguous')",
        'dists1d'   : "ndpointer(%(restype), ndim=1, flags='aligned, c_contiguous, writeable')",
        'result_ids' : "ndpointer(int32, ndim=2, flags='aligned, c_contiguous, writeable')",
        #'query'   : "ndpointer(float64, ndim=1, flags='aligned, c_contiguous')",
    }

    for key, val in templated_ctype_map.items():
        if key not in python_ctype_map:
            python_ctype_map[key] = simple_c_to_ctypes[val]

    # default c source
    c_source = ut.codeblock(
        '''
        TODO: IMPLEMENT THIS FUNCTION WRAPPER
        '''
    )

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
    cpp_binding_name = binding_name

    if binding_name == 'clean_removed_points':
        cpp_binding_name = ut.to_camel_case(binding_name)
        return_type = 'void'
        docstr = ut.codeblock(
            '''
            Deletes removed points in index?
            '''
        )
        binding_argnames = [
            INDEX_PTR_NAME,
        ]
        c_source = standard_csource
    elif binding_name == 'veclen':
        return_type = 'int'
        docstr = ut.codeblock(
            '''
            Returns number of features in this index
            '''
        )
        binding_argnames = [
            INDEX_PTR_NAME,
        ]
        c_source = standard_csource
    elif binding_name == 'size':
        return_type = 'int'
        docstr = ut.codeblock(
            '''
            returns The dimensionality of the features in this index.
            '''
        )
        binding_argnames = [
            INDEX_PTR_NAME,
        ]
        c_source = standard_csource.format(**locals())
    elif binding_name == 'getType':
        return_type = 'flann_algorithm_t'
        docstr = ut.codeblock(
            '''
            returns The index type (kdtree, kmeans,...)
            '''
        )
        binding_argnames = [
            INDEX_PTR_NAME,
        ]
        c_source = standard_csource.format(**locals())
    elif binding_name == 'used_memory':
        return_type = 'int'
        docstr = ut.codeblock(
            '''
            Returns the amount of memory used by the index

            Returns: int
            '''
        )
        binding_argnames = [
            INDEX_PTR_NAME,
        ]
        c_source = ut.codeblock(
            r'''
            typedef typename Distance::ElementType ElementType;
            try {{
                if (index_ptr==NULL) {{
                    throw FLANNException("Invalid index");
                }}
                Index<Distance>* index = (Index<Distance>*)index_ptr;
                return index->usedMemory();
            }}
            catch (std::runtime_error& e) {{
                Logger::error("Caught exception: %s\n",e.what());
                throw;
            }}
            '''
        )
    elif binding_name == 'add_points':
        return_type = 'void'
        docstr = ut.codeblock(
            '''
            Adds points to an index.

            Params:
                index_ptr The index that should be modified
                dataset = pointer to a data set stored in row major order
                rows = number of rows (features) in the dataset
                cols = number of columns in the dataset (feature dimensionality)
                rebuild_threadhold

            Returns: void
            ''')
        binding_argnames = [
            INDEX_PTR_NAME,
            'dataset',
            'rows',
            'rebuild_threshold',
        ]
        c_source = ut.codeblock(
            r'''
            typedef typename Distance::ElementType ElementType;
            try {{
                if (index_ptr==NULL) {{
                    throw FLANNException("Invalid index");
                }}
                Index<Distance>* index = (Index<Distance>*)index_ptr;
                Matrix<ElementType> points = Matrix<ElementType>(dataset,rows,index->veclen());
                index->addPoints(points, rebuild_threshhold);
                return;
            }}
            catch (std::runtime_error& e) {{
                Logger::error("Caught exception: %s\n",e.what());
                return;
            }}
            '''
        )
    elif binding_name == 'remove_point':
        return_type = 'void'
        docstr = ut.codeblock(
            '''
            Removes a point from the index

            Params:
                index_ptr The index that should be modified
                id = point id to be removed

            Returns: void
            '''
        )
        binding_argnames = [
            INDEX_PTR_NAME,
            'id_',
        ]
        c_source = ut.codeblock(
            r'''
            typedef typename Distance::ElementType ElementType;
            try {{
                if (index_ptr==NULL) {{
                    throw FLANNException("Invalid index");
                }}
                Index<Distance>* index = (Index<Distance>*)index_ptr;
                index->removePoint(id_);
                return;
            }}
            catch (std::runtime_error& e) {{
                Logger::error("Caught exception: %s\n",e.what());
                return;
            }}
            '''
        )
    elif binding_name == 'remove_points':
        return_type = 'void'
        docstr = ut.codeblock(
            '''
            Removes a point from the index

            Params:
                index_ptr The index that should be modified
                id_list = list of point ids to be removed

            Returns: void
            '''
        )
        binding_argnames = [
            INDEX_PTR_NAME,
            'id_list',
            'num',
        ]
        c_source = ut.codeblock(
            r'''
            typedef typename Distance::ElementType ElementType;
            try {{
                if (index_ptr==NULL) {{
                    throw FLANNException("Invalid index");
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
    elif binding_name == 'compute_cluster_centers':
        docstr = ''
        return_type = 'int'
        binding_argnames = ['dataset', 'rows', 'cols', 'clusters', 'result_centers',
                            'flann_params']
    elif binding_name == 'radius_search':
        docstr = ''
        return_type = 'int'
        binding_argnames = [INDEX_PTR_NAME, 'query1d', 'indices', 'dists1d', 'max_nn',
                            'radius', 'flann_params', ]
    elif binding_name == 'find_nearest_neighbors_index':
        docstr = ''
        return_type = 'int'
        binding_argnames = [INDEX_PTR_NAME, 'testset', 'tcount', 'result_ids',
                            'dists', 'nn', 'flann_params', ]
    elif binding_name == 'find_nearest_neighbors':
        docstr = ''
        return_type = 'int'
        binding_argnames = ['dataset', 'rows', 'cols', 'testset', 'tcount',
                            'result_ids', 'dists', 'nn', 'flann_params']
    elif binding_name == 'load_index':
        docstr = ''
        return_type = 'flann_index_t'
        binding_argnames = ['filename', 'dataset', 'rows', 'cols']
    elif binding_name == 'save_index':
        docstr = ''
        return_type = 'void'
        binding_argnames = [INDEX_PTR_NAME, 'filename']
    elif binding_name == 'build_index':
        docstr = ''
        return_type = 'flann_index_t'
        binding_argnames = ['dataset', 'rows', 'cols', 'speedup', 'flann_params']
    elif binding_name == 'free_index':
        docstr = ''
        return_type = 'void'
        binding_argnames = ['index_id', 'flann_params']
    else:
        raise NotImplementedError('Unknown binding name %r' % (binding_name,))
    binding_args = [python_ctype_map[name] + ',  # ' + name for name in binding_argnames]
    binding_args_str = '        ' + '\n        '.join(binding_args)
    templated_args = ', '.join([templated_ctype_map[name] + ' ' + name for name in binding_argnames])
    callargs = ', '.join(binding_argnames)
    pycallargs = ', '.join([name for name in binding_argnames if name != 'index_ptr'])
    pyinputargs = pycallargs  # FIXME

    pyrestype = simple_c_to_ctypes[return_type]

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

    flann_index_codeblock = ut.codeblock(
        r'''
        def {binding_name}(self, {pyinputargs}):
            """''' + ut.indent('\n' + docstr, '            ') + '''
            """
            if pts.dtype.type not in allowed_types:
                raise FLANNException("Cannot handle type: %s" % pts.dtype)
            pts = ensure_2d_array(pts, default_flags)
            rows = pts.shape[0]
            raise NotImplementedError('requires custom implementation')
            flann.{binding_name}[self.__curindex_type](self.__curindex, {pycallargs})
        '''
    ).format(binding_name=binding_name, pycallargs=pycallargs, pyinputargs=pyinputargs)

    templated_ctype_map2 = dict(**templated_ctype_map)
    templated_ctype_map2['dataset'] = 'T*'
    typed_sigargs = ', '.join([templated_ctype_map2[name] + ' ' + name for name in binding_argnames])

    flann_c_code_fmtstr = ut.codeblock(
        r'''
        // {binding_name} BEGIN
        template<typename Distance>
        {return_type} __flann_{binding_name}({templated_args})
        {{
            ''' + '\n' + ut.indent(c_source, ' ' * (4 * 3)) + r'''
        }}

        '''
    )

    implicit_type_bindings_fmtstr = ut.codeblock(
        '''
        DISTANCE_TYPE_BINDINGS({return_type}, {binding_name},
                SINGLE_ARG({typed_sigargs}),
                SINGLE_ARG({callargs}))

        '''
    )

    explicit_type_bindings_fmtstr = ut.codeblock(
        '''
        template<typename T>
        {return_type} _flann_{binding_name}({typed_sigargs})
        {{
            if (flann_distance_type==FLANN_DIST_EUCLIDEAN) {{
                 return __flann_{binding_name}<L2<T> >({callargs});
            }}
            else if (flann_distance_type==FLANN_DIST_MANHATTAN) {{
                 return __flann_{binding_name}<L1<T> >({callargs});
            }}
            else if (flann_distance_type==FLANN_DIST_MINKOWSKI) {{
                 return __flann_{binding_name}<MinkowskiDistance<T> >({callargs});
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
                throw 0;
            }}
        }}
        '''
    )
    #type_bindings_fmtstr = explicit_type_bindings_fmtstr
    type_bindings_fmtstr = implicit_type_bindings_fmtstr

    flann_c_codeblock_fmtstr = flann_c_code_fmtstr + '\n\n\n' + type_bindings_fmtstr + '\n'

    flann_c_codeblock = flann_c_codeblock_fmtstr.format(
        cpp_binding_name=cpp_binding_name,
        binding_name=binding_name,
        templated_args=templated_args, callargs=callargs,
        typed_sigargs=typed_sigargs,
        return_type=return_type)

    dataset_types = [
        '',
        'float',
        'double',
        'int',
        'byte',
    ]

    header_sigs = []
    body_blocks = []
    body_block_fmtstr = ut.codeblock(
        '''
        {return_type} flann_{binding_name}{signame_type}({typed_sigargs})
        {{
            _flann_{binding_name}<{T_type}>({callargs});
        }}
        '''
    )
    headersig_fmstr_ = 'FLANN_EXPORT {return_type} flann_{binding_name}{signame_type}({typed_sigargs});'
    templated_ctype_map2['dataset'] = 'float'

    for signame_type in dataset_types:
        if signame_type == '':
            T_type = 'float'
        else:
            if signame_type == 'byte':
                T_type = 'unsigned char'
            else:
                T_type = signame_type
            signame_type = '_' + signame_type
        dstype = T_type + '*'
        templated_ctype_map2['dataset'] = dstype

        typed_sigargs = ', '.join([templated_ctype_map2[name] + ' ' + name for name in binding_argnames])
        header_line = headersig_fmstr_.format(signame_type=signame_type,
                                              dstype=dstype,
                                              typed_sigargs=typed_sigargs,
                                              binding_name=binding_name,
                                              return_type=return_type)
        bodyblock = body_block_fmtstr.format(signame_type=signame_type,
                                             dstype=dstype,
                                             typed_sigargs=typed_sigargs,
                                             binding_name=binding_name,
                                             callargs=callargs, T_type=T_type,
                                             return_type=return_type)
        header_sigs.append(header_line)
        body_blocks.append(bodyblock)

    flann_c_codeblock += '\n' + '\n'.join(body_blocks)
    flann_c_codeblock += '\n' + '// {binding_name} END'.format(binding_name=binding_name)

    flann_h_codeblock = ut.codeblock(
        r'''
        /** {binding_name}
        {docstr}
         */
        '''
    ).format(docstr=docstr, binding_name=binding_name) + '\n\n' +  '\n\n'.join(header_sigs)

    flann_h_codeblock = flann_h_codeblock

    blocks_dict = {}
    blocks_dict['flann_ctypes.py'] = flann_ctypes_codeblock
    blocks_dict['index.py'] = flann_index_codeblock
    blocks_dict['flann.h'] = flann_h_codeblock
    blocks_dict['flann.cpp'] = flann_c_codeblock

    flann_ctypes_codeblock

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
        print(flann_c_codeblock)
    #print('-------')

    #FLANN_EXPORT void flann_{binding_name}(flann_index_t index_id, float* dataset, int rows, int rebuild_threshold);

    #FLANN_EXPORT void flann_{binding_name}_float(flann_index_t index_id, float* dataset, int rows, int rebuild_threshold);

    #FLANN_EXPORT void flann_{binding_name}_double(flann_index_t index_id, double* dataset, int rows, int rebuild_threshold);

    #FLANN_EXPORT void flann_{binding_name}_int(flann_index_t index_id, int* dataset, int rows, int rebuild_threshold);

    #FLANN_EXPORT void flann_{binding_name}_byte(flann_index_t index_id, unsigned char* dataset, int rows, int rebuild_threshold);
    return blocks_dict

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
