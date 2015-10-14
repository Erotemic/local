
import utool as ut


def autogen_parts():
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

    binding_name = ut.get_argval('--bindingname', type_=str, default='add_points')

    templated_ctype_map = {
        'dataset': 'typename Distance::ElementType*',
        'index_ptr': 'flann_index_t',
        'rows': 'int',
        'rebuild_threshold': 'int',
        'id_': 'int',
        'id_list': 'int*',
        'num': 'int',
    }

    python_ctype_map = {
        'index_ptr': 'FLANN_INDEX',
        'dataset': "ndpointer(%(numpy)s, ndim = 2, flags='aligned, c_contiguous')",
        'rows': 'c_int',
        'id_': 'c_int',
        'rebuild_threshold': 'c_int',
        #'id_list': 'POINTER(c_int)',
        'id_list': "ndpointer(int32, ndim = 1, flags='aligned, c_contiguous')",
        'num': 'c_int',
    }

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
            'index_ptr',
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
            'index_ptr',
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
            'index_ptr',
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
            'index_ptr',
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
            'index_ptr',
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
                index_id The index that should be modified
                dataset = pointer to a data set stored in row major order
                rows = number of rows (features) in the dataset
                cols = number of columns in the dataset (feature dimensionality)
                rebuild_threadhold

            Returns: void
            ''')
        binding_argnames = [
            'index_ptr',
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
                index_id The index that should be modified
                id = point id to be removed

            Returns: void
            '''
        )
        binding_argnames = [
            'index_ptr',
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
                index_id The index that should be modified
                id_list = list of point ids to be removed

            Returns: void
            '''
        )
        binding_argnames = [
            'index_ptr',
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
    else:
        raise NotImplementedError('Unknown binding name %r' % (binding_name,))
    binding_args = [python_ctype_map[name] + ',  # ' + name for name in binding_argnames]
    binding_args_str = '        ' + '\n        '.join(binding_args)
    templated_args = ', '.join([templated_ctype_map[name] + ' ' + name for name in binding_argnames])
    callargs = ', '.join(binding_argnames)
    pycallargs = ', '.join([name for name in binding_argnames if name != 'index_ptr'])
    pyinputargs = pycallargs  # FIXME

    pyrestype = None if return_type == 'void' else 'c_' + return_type

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

    flann_c_codeblock_fmtstr = flann_c_code_fmtstr + '\n\n' + type_bindings_fmtstr + '\n'

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
        /**
        {docstr}
         */
        '''.format(docstr=docstr)
    ) + '\n\n' +  '\n\n'.join(header_sigs)

    flann_h_codeblock = flann_h_codeblock

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

    print('-------')

    #FLANN_EXPORT void flann_{binding_name}(flann_index_t index_id, float* dataset, int rows, int rebuild_threshold);

    #FLANN_EXPORT void flann_{binding_name}_float(flann_index_t index_id, float* dataset, int rows, int rebuild_threshold);

    #FLANN_EXPORT void flann_{binding_name}_double(flann_index_t index_id, double* dataset, int rows, int rebuild_threshold);

    #FLANN_EXPORT void flann_{binding_name}_int(flann_index_t index_id, int* dataset, int rows, int rebuild_threshold);

    #FLANN_EXPORT void flann_{binding_name}_byte(flann_index_t index_id, unsigned char* dataset, int rows, int rebuild_threshold);

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
