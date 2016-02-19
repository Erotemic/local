
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
        'find_nearest_neighbors_index',
        'find_nearest_neighbors',
        'load_index',
        'save_index',
        'build_index',
        'free_index',
        'radius_search',

        #'size',
        #'veclen',
        #'get_point',
        #'flann_get_distance_order',
        #'flann_get_distance_type',
        #'flann_log_verbosity',
    ]

    _places = [
        '~/code/flann/src/cpp/flann/flann.cpp',
        '~/code/flann/src/cpp/flann/flann.h',
        '~/code/flann/src/python/pyflann/flann_ctypes.py',
        '~/code/flann/src/python/pyflann/index.py',
    ]

    eof_sentinals = {
        #'flann_ctypes.py': '# END DEFINE BINDINGS',
        #'flann.h': '// END DEFINE BINDINGS',
        'flann.cpp': None,
        #'index.py': '$'
    }
    block_sentinals = {
        'flann.h': '/**',
        'flann.cpp': 'template <typename Distance>',
    }
    from os.path import basename
    places = {basename(fpath): fpath for fpath in ut.lmap(ut.truepath, _places)}
    text_dict = ut.map_dict_vals(ut.readfrom, places)
    lines_dict = {key: val.split('\n') for key, val in text_dict.items()}
    orig_texts = text_dict.copy()  # NOQA

    import difflib
    import numpy as np
    import re

    named_blocks = {binding_name: autogen_parts(binding_name) for binding_name in binding_names}

    for binding_name in ut.ProgIter(binding_names):
        blocks_dict = named_blocks[binding_name]
        for key in eof_sentinals.keys():
            # key = 'flann_ctypes.py'
            # print(text_dict[key])
            old_text = text_dict[key]
            line_list = lines_dict[key]
            #text = old_text
            block = blocks_dict[key]

            # Find a place in the code that already exists

            searchblock = block
            if key.endswith('.cpp') or key.endswith('.h'):
                searchblock = re.sub(ut.REGEX_C_COMMENT, '', searchblock,
                                     flags=re.MULTILINE | re.DOTALL)
            sm = difflib.SequenceMatcher(None, old_text, searchblock, autojunk=False)
            matchtups = sm.get_matching_blocks()
            # Find a reasonable match in matchtups
            found = False
            for (a, b, size) in matchtups:
                matchtext = old_text[a: a + size]
                if re.search(binding_name + '\\b', matchtext):
                    found = True
                    pos = a + size
                    if False:
                        print(matchtext)
                    break

            #import utool
            #utool.embed()

            #largest_ = ut.argsort(ut.take_column(matchtups, 2))[-1]
            #(a, b, size) = matchtups[largest_]
            # print()

            #import utool
            #utool.embed()
            #print('size = %r' % (size,))
            if found:
                linelens = np.array(ut.lmap(len, line_list)) + 1
                sumlen = np.cumsum(linelens)
                row = np.where(sumlen < pos)[0][-1] + 1
                #print(line_list[row])
                # Search for extents of the block to overwrite
                block_sentinal = block_sentinals[key]
                row1 = ut.find_block_end(row, line_list, re.escape(block_sentinal), -1)
                row2 = ut.find_block_end(row + 1, line_list, re.escape(block_sentinal), +1)
                if False:
                    print('\n'.join(line_list[row1:row2]))
                new_line_list = ut.insert_block_between_lines(
                    block + '\n\n', row1 - 1, row2, line_list)
            else:
                # Append to end of the file
                eof_sentinal = eof_sentinals[key]
                if eof_sentinal is None:
                    row2 = len(line_list) - 1
                else:
                    #block = 'MISSED ' + binding_name
                    row2 = [count for count, line in enumerate(line_list)
                            if line.startswith(eof_sentinal)][-1]

                new_line_list = ut.insert_block_between_lines(
                    block + '\n\n', row2 - 1, row2, line_list)

            #print(ut.msgblock(binding_name, block))
            #blockid = block.split('\n')[0]
            #if False:
            #    blockpos = text.find(blockid)
            #    if blockpos == -1:
            #        sentinal = eof_sentinals[key]
            #        #print('sentinal = %r' % (sentinal,))
            #        new_text = ut.insert_before_sentinal(old_text, '\n' + block + '\n\n', sentinal)
            #    else:
            #        startpos = blockpos
            #        #def find_block_endpos(startpos):
            #        rel_endpos = text[startpos:].find('\n\n\n')
            #        assert rel_endpos != -1
            #        endpos = startpos + rel_endpos
            #        new_text = old_text[:startpos] + block + old_text[endpos:]
            text_dict[key] = '\n'.join(new_line_list)
            lines_dict[key] = new_line_list

        #print(ut.get_colored_diff(ut.get_textdiff(old_text, new_text, num_context_lines=5)))
    new_text = '\n'.join(lines_dict[key])
    print(ut.get_colored_diff(ut.get_textdiff(orig_texts[key], new_text, num_context_lines=5, ignore_whitespace=True)))


def define_flann_bindings(binding_name):
    """
    Define the binding names for flann
    """
    # default c source
    c_source = None
    optional_args = None
    c_source_part = None

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
            Returns the amount of memory (in bytes) used by the index

            index_ptr = pointer to pre-built index.

            Returns: int
            '''
        )
        binding_argnames = [
            'index_ptr',
        ]
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
    elif binding_name == 'add_points':
        #return_type = 'void'
        return_type = 'int'
        docstr = ut.codeblock(
            '''
            Adds points to pre-built index.

            Params:
                index_ptr The index that should be modified
                dataset = pointer to a data set stored in row major order
                rows = number of rows (features) in the dataset
                cols = number of columns in the dataset (feature dimensionality)
                rebuild_threadhold = reallocs index when it grows by factor of
                   `rebuild_threshold`. A smaller value results is more space
                    efficient but less computationally efficient. Must be greater than 1.

            Returns: 0 if success otherwise -1
            ''')
        binding_argnames = [
            'index_ptr',
            'points',
            'rows',
            'cols',  # TODO: can remove
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
                Matrix<ElementType> points = Matrix<ElementType>(dataset, rows, index->veclen());
                index->addPoints(points, rebuild_threshhold);
                return 0;
            }}
            catch (std::runtime_error& e) {{
                Logger::error("Caught exception: %s\n",e.what());
                return -1;
            }}
            '''
        )
    elif binding_name == 'remove_point':
        #return_type = 'void'
        return_type = 'int'
        docstr = ut.codeblock(
            '''
            Removes a point from the index

            Params:
                index_ptr = The index that should be modified
                id = point id to be removed

            Returns: void
            '''
        )
        binding_argnames = [
            'index_ptr',
            'point_id',
        ]
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
    elif binding_name == 'remove_points':
        return_type = 'void'
        docstr = ut.codeblock(
            '''
            Removes multiple points from the index

            Params:
                index_ptr = The index that should be modified
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
    elif binding_name == 'compute_cluster_centers':
        docstr = ut.codeblock(
            r'''
            Clusters the features in the dataset using a hierarchical kmeans clustering approach.
            This is significantly faster than using a flat kmeans clustering for a large number
            of clusters.

            Params:
                dataset = pointer to a data set stored in row major order
                rows = number of rows (features) in the dataset
                cols = number of columns in the dataset (feature dimensionality)
                clusters = number of cluster to compute
                result_centers = memory buffer where the output cluster centers are storred
                index_params = used to specify the kmeans tree parameters (branching factor, max number of iterations to use)
                flann_params = generic flann parameters

            Returns: number of clusters computed or a number <0 for error. This number can
                be different than the number of clusters requested, due to the way
                hierarchical clusters are computed. The number of clusters returned will be
                the highest number of the form (branch_size-1)*K+1 smaller than the number
                of clusters requested.
            ''')

        return_type = 'int'
        binding_argnames = ['dataset', 'rows', 'cols', 'clusters', 'result_centers',
                            'flann_params']
    elif binding_name == 'radius_search':
        docstr = ut.codeblock(
            r'''
            * Performs an radius search using an already constructed index.
            *
            * In case of radius search, instead of always returning a predetermined
            * number of nearest neighbours (for example the 10 nearest neighbours), the
            * search will return all the neighbours found within a search radius
            * of the query point.
            *
            * The check parameter in the FLANNParameters below sets the level of approximation
            * for the search by only visiting "checks" number of features in the index
            * (the same way as for the KNN search). A lower value for checks will give
            * a higher search speedup at the cost of potentially not returning all the
            * neighbours in the specified radius.

            Params:
                index_ptr = the index
                query1d = query point
                result_ids = array for storing the indices found (will be modified)
                dists1d = similar, but for storing distances
                max_nn = size of arrays result_ids and dists1d
                radius = search radius (squared radius for euclidian metric)
                flann_params = params
            ''')
        return_type = 'int'
        binding_argnames = ['index_ptr', 'query1d', 'result_ids', 'dists1d', 'max_nn',
                            'radius', 'flann_params', ]

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

    elif binding_name == 'find_nearest_neighbors_index':
        docstr = ut.codeblock(
            '''
            Searches for nearest neighbors using the index provided

            Params:
                index_ptr = the index (constructed previously using flann_build_index).
                testset = pointer to a query set stored in row major order
                tcount = number of rows (features) in the query dataset (same dimensionality as features in the dataset)
                result_ids = pointer to matrix for the indices of the nearest neighbors of the testset features in the dataset
                    (must have tcount number of rows and nn number of columns)
                dists = pointer to matrix for the distances of the nearest neighbors of the testset features in the dataset
                    (must have tcount number of rows and 1 column)
                nn = how many nearest neighbors to return
                flann_params = generic flann parameters

            Returns: zero or a number <0 for error
            ''')
        return_type = 'int'
        binding_argnames = ['index_ptr', 'testset', 'tcount', 'result_ids',
                            'dists', 'nn', 'flann_params', ]
    elif binding_name == 'find_nearest_neighbors':
        docstr = ut.codeblock(
            '''
            Builds an index and uses it to find nearest neighbors.

            Params:
                dataset = pointer to a data set stored in row major order
                rows = number of rows (features) in the dataset
                cols = number of columns in the dataset (feature dimensionality)
                testset = pointer to a query set stored in row major order
                tcount = number of rows (features) in the query dataset (same dimensionality as features in the dataset)
                result_ids = pointer to matrix for the indices of the nearest neighbors of the testset features in the dataset
                    (must have tcount number of rows and nn number of columns)
                nn = how many nearest neighbors to return
                flann_params = generic flann parameters

            Returns: zero or -1 for error
            ''')
        return_type = 'int'
        binding_argnames = ['dataset', 'rows', 'cols', 'testset', 'tcount',
                            'result_ids', 'dists', 'nn', 'flann_params']
        optional_args = ['Distance d = Distance()']
    elif binding_name == 'load_index':
        docstr = ut.codeblock(
            '''
            * Loads an index from a file.
            *
            * @param filename File to load the index from.
            * @param dataset The dataset corresponding to the index.
            * @param rows Dataset tors
            * @param cols Dataset columns
            * @return
            ''')
        c_source_part = ut.codeblock(
            r'''
            Index<Distance>* index = new Index<Distance>(Matrix<typename Distance::ElementType>(dataset,rows,cols), SavedIndexParams(filename), d);
            return index;
            '''
        )
        return_type = 'flann_index_t'
        binding_argnames = ['filename', 'dataset', 'rows', 'cols']
        optional_args = ['Distance d = Distance()']
    elif binding_name == 'save_index':
        docstr = ut.codeblock(
            '''
             * Saves the index to a file. Only the index is saved into the
             * file, the dataset corresponding to the index is not saved.
             *
             * @param index_ptr The index that should be saved
             * @param filename The filename the index should be saved to
             * @return Returns 0 on success, negative value on error.
            ''')
        c_source_part = ut.codeblock(
            r'''
            Index<Distance>* index = (Index<Distance>*)index_ptr;
            index->save(filename);

            return 0;
            ''')
        return_type = 'int'
        binding_argnames = ['index_ptr', 'filename']
    elif binding_name == 'build_index':
        docstr = ut.codeblock(
            """
            Builds and returns an index. It uses autotuning if the target_precision field of index_params
            is between 0 and 1, or the parameters specified if it's -1.

            Params:
                dataset = pointer to a data set stored in row major order
                rows = number of rows (features) in the dataset
                cols = number of columns in the dataset (feature dimensionality)
                speedup = speedup over linear search, estimated if using autotuning, output parameter
                index_params = index related parameters
                flann_params = generic flann parameters

            Returns: the newly created index or a number <0 for error
            """)

        return_type = 'flann_index_t'
        binding_argnames = ['dataset', 'rows', 'cols', 'speedup', 'flann_params']
    elif binding_name == 'free_index':
        docstr = ut.codeblock(
            '''
            Deletes an index and releases the memory used by it.

            Params:
                index_ptr = the index (constructed previously using flann_build_index).
                flann_params = generic flann parameters

            Returns: zero or a number <0 for error
            ''')

        c_source_part = ut.codeblock(
            r'''
            Index<Distance>* index = (Index<Distance>*)index_ptr;
            delete index;

            return 0;
            ''')
        return_type = 'int'
        binding_argnames = ['index_ptr', 'flann_params']
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
                part1 = try_ + '\n' + 'init_flann_parameters(flann_params);' + throw_
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

    binding_def = {
        'cpp_binding_name': cpp_binding_name,
        'docstr': docstr,
        'return_type': return_type,
        'binding_argnames': binding_argnames,
        'c_source': c_source,
        'optional_args': optional_args,
    }

    return binding_def


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
        'typename Distance::ElementType*' : "ndpointer(%(numpy)s, ndim=2, flags='aligned, c_contiguous')",
        'typename Distance::ResultType*'  : "ndpointer(%(restype), ndim=2, flags='aligned, c_contiguous, writeable')",
    }

    templated_ctype_map = {
        'filename'          : 'char*',
        'rows'              : 'int',
        'cols'              : 'int',
        #'id_'               : 'int',
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
        'result_centers'    : 'Distance::ResultType*',
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
    docstr           = binding_def['docstr']
    cpp_binding_name = binding_def['cpp_binding_name']
    return_type      = binding_def['return_type']
    binding_argnames = binding_def['binding_argnames']
    c_source         = binding_def['c_source']
    optional_args = binding_def['optional_args']

    binding_args = [python_ctype_map[name] + ',  # ' + name for name in binding_argnames]
    binding_args_str = '        ' + '\n        '.join(binding_args)
    callargs = ', '.join(binding_argnames)
    pycallargs = ', '.join([name for name in binding_argnames if name != 'index_ptr'])
    pyinputargs = pycallargs  # FIXME

    pyrestype = simple_c_to_ctypes[return_type]

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

    #### flann.cpp

    flann_cpp_code_fmtstr = ut.codeblock(
        r'''
        // {binding_name} BEGIN CPP BINDING
        template <typename Distance>
        {return_type} __flann_{binding_name}({templated_args})
        {{
            ''' + '\n' + ut.indent(c_source, ' ' * (4 * 3)) + r'''
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

    explicit_type_bindings_fmtstr = ut.codeblock(
        r'''
        // DISTANCE TYPE TEMPLATE
        template <{used_templates}>
        {return_type} _flann_{binding_name}({T_typed_sigargs_cpp})
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
    type_bindings_fmtstr = explicit_type_bindings_fmtstr

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
    c_headersig_fmtstr = 'FLANN_EXPORT {return_type} flann_{binding_name}{signame_type}({T_typed_sigargs2});'

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
    T_typed_sigargs_cpp = ', '.join(binding_sigargs_cpp)

    flann_cpp_codeblock_fmtstr = flann_cpp_code_fmtstr + '\n\n\n' + type_bindings_fmtstr + '\n'

    used_template_list = []
    used_template_list.append('typename T')
    if 'typename Distance::ResultType*' in binding_argtypes:
        used_template_list.append('typename R')

    if binding_name == 'remove_point':
        # HACK
        templated_args += '_uint'

    if return_type == 'int':
        errorhandle = 'return -1;'
    elif return_type == 'flann_index_t':
        errorhandle = 'return NULL;'
    else:
        errorhandle = 'throw 0;'

    used_templates = ', '.join(used_template_list)

    flann_cpp_codeblock = flann_cpp_codeblock_fmtstr.format(
        cpp_binding_name=cpp_binding_name,
        minkowski_option=minkowski_option,
        binding_name=binding_name,
        templated_args=templated_args, callargs=callargs,
        T_typed_sigargs_cpp=T_typed_sigargs_cpp,
        errorhandle=errorhandle,
        used_templates=used_templates,
        return_type=return_type)

    dataset_types = [
        '',
        'float',
        'double',
        'int',
        'byte',
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
        if binding_name == 'load_index' or binding_name == 'add_points':
            needstemplate = True
        binding_argtypes2 = ut.dict_take(templated_ctype_map_c, binding_argnames)
        binding_sigargs2 = [type_ + ' ' + name for type_, name in
                            zip(binding_argtypes2, binding_argnames)]
        T_typed_sigargs2 = ', '.join(binding_sigargs2)
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
        # Hack for header
        T_typed_sigargs2 = T_typed_sigargs2.replace('FLANNParameters* flann_params', 'struct FLANNParameters* flann_params')

        header_line = c_headersig_fmtstr.format(signame_type=signame_type,
                                                T_typed_sigargs2=T_typed_sigargs2,
                                                binding_name=binding_name,
                                                return_type=return_type)
        c_header_sigs.append(header_line)
        c_body_blocks.append(bodyblock)

    flann_cpp_codeblock += '\n' + '\n'.join(c_body_blocks)
    flann_cpp_codeblock += '\n' + '// {binding_name} END'.format(binding_name=binding_name)

    flann_h_codeblock = ut.codeblock(
        r'''
        /** BEGIN {binding_name}
        {docstr}
         */
        '''
    ).format(docstr=docstr, binding_name=binding_name)
    flann_h_codeblock += '\n\n' +  '\n\n'.join(c_header_sigs)

    blocks_dict = {}
    blocks_dict['flann_ctypes.py'] = flann_ctypes_codeblock
    blocks_dict['index.py'] = flann_index_codeblock
    blocks_dict['flann.h'] = flann_h_codeblock
    blocks_dict['flann.cpp'] = flann_cpp_codeblock

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
    #print('-------')

    #FLANN_EXPORT void flann_{binding_name}(flann_index_t index_ptr, float* dataset, int rows, int rebuild_threshold);

    #FLANN_EXPORT void flann_{binding_name}_float(flann_index_t index_ptr, float* dataset, int rows, int rebuild_threshold);

    #FLANN_EXPORT void flann_{binding_name}_double(flann_index_t index_ptr, double* dataset, int rows, int rebuild_threshold);

    #FLANN_EXPORT void flann_{binding_name}_int(flann_index_t index_ptr, int* dataset, int rows, int rebuild_threshold);

    #FLANN_EXPORT void flann_{binding_name}_byte(flann_index_t index_ptr, unsigned char* dataset, int rows, int rebuild_threshold);
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
