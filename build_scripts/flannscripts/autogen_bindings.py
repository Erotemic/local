# -*- coding: utf-8 -*-
from __future__ import absolute_import, division, print_function, unicode_literals
import utool as ut
(print, rrr, profile) = ut.inject2(__name__, '[ibs]')


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
        # 'used_memory',
        # 'add_points',
        # 'remove_point',

        # 'compute_cluster_centers',
        # 'load_index',
        # 'save_index',
        # 'find_nearest_neighbors',

        # 'radius_search',
        # 'remove_points',
        # 'free_index',
        # 'find_nearest_neighbors_index',

        # 'size',
        # 'veclen',
        # 'get_point',
        # 'flann_get_distance_order',
        # 'flann_get_distance_type',
        # 'flann_log_verbosity',

        # 'clean_removed_points',

    ]

    _places = [
        # '~/code/flann/src/cpp/flann/flann.cpp',
        # '~/code/flann/src/cpp/flann/flann.h',
        # '~/code/flann/src/python/pyflann/flann_ctypes.py',
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
                matchtups = sm.get_matching_blocks() + sm0.get_matching_blocks() + sm1.get_matching_blocks() + sm2.get_matching_blocks()
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
                    print(ut.get_colored_diff(ut.difftext(rtext1, rtext2, num_context_lines=7, ignore_whitespace=True)))
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
                    print(ut.get_colored_diff(ut.difftext(rtext1, rtext2, num_context_lines=7, ignore_whitespace=True)))
            text_dict[key] = '\n'.join(new_line_list)
            lines_dict[key] = new_line_list
        ut.colorprint('L___  GENERATED BINDING %s ___' % (binding_name,), 'yellow')
    new_text = '\n'.join(lines_dict[key])
    ut.writeto(ut.augpath(places[key], '.new'), new_text)
    if ut.get_argflag('--diff'):
        difftext = ut.get_textdiff(orig_texts[key], new_text,
                                   num_context_lines=7, ignore_whitespace=True)
        difftext = ut.get_colored_diff(difftext)
        print(difftext)


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
        'dists': 'pointer to matrix for the distances of the nearest neighbors of the testset features in the dataset',
        'flann_params': 'generic flann parameters',
        'index_ptr': 'the index (constructed previously using flann_build_index)',
        'nn': 'how many nearest neighbors to return',
        'rebuild_threadhold': 'reallocs index when it grows by factor of `rebuild_threshold`. A smaller value results is more space efficient but less computationally efficient. Must be greater than 1.',
        'result_ids': 'pointer to matrix for the indices of the nearest neighbors of the testset features in the dataset (must have tcount number of rows and nn number of columns)',
        'rows': 'number of rows (features) in the dataset',
        'tcount': 'number of rows (features) in the query dataset (same dimensionality as features in the dataset)',
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
        c_source = standard_csource
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
        c_source = standard_csource
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
        py_source = ut.codeblock(
            '''
            if self.__curindex is None:
                return 0
            return flann.used_memory[self.__curindex_type](self.__curindex)
            ''')
    elif binding_name == 'add_points':
        #return_type = 'void'
        return_type = 'int'
        docstr = ut.codeblock(
            '''
            Adds points to pre-built index.
            ''')
        binding_argnames = [
            'index_ptr',
            'points',
            'rows',
            'cols',  # TODO: can remove
            'rebuild_threshold',
        ]
        return_doc = '0 if success otherwise -1'
        cpp_param_doc['points'] = 'pointer to array of points'
        cpp_param_doc['rebuild_threshold'] = 'reallocs index when it grows by factor of `rebuild_threshold`. A smaller value results is more space efficient but less computationally efficient. Must be greater than 1.'
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
        py_args = ['new_pts', 'rebuild_threshold=2.']
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
    elif binding_name == 'remove_point':
        #return_type = 'void'
        return_type = 'int'
        docstr = ut.codeblock(
            '''
            Removes a point from the index
            '''
        )
        return_doc = zero_success
        cpp_param_doc['point_id'] = 'point id to be removed'
        cpp_param_doc['index_ptr'] = 'The index that should be modified'
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
        py_source = ut.codeblock(
            '''
            flann.remove_point[self.__curindex_type](self.__curindex, point_id)
            self.__removed_ids.append(point_id)
            ''')
    elif binding_name == 'remove_points':
        return_type = 'void'
        docstr = ut.codeblock(
            '''
            Removes multiple points from the index
            '''
        )
        return_doc = 'void'
        cpp_param_doc['index_ptr'] = 'The index that should be modified'
        cpp_param_doc['id_list'] = 'list of point ids to be removed'
        cpp_param_doc['num'] = 'number of points in id_list'
        binding_argnames = ['index_ptr', 'id_list', 'num']
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
        py_args = ['id_list']

    elif binding_name == 'compute_cluster_centers':
        docstr = ut.codeblock(
            r'''
            Clusters the features in the dataset using a hierarchical kmeans clustering approach.
            This is significantly faster than using a flat kmeans clustering for a large number
            of clusters.
            ''')

        return_doc = 'number of clusters computed or a number <0 for error. This number can be different than the number of clusters requested, due to the way hierarchical clusters are computed. The number of clusters returned will be the highest number of the form (branch_size-1)*K+1 smaller than the number of clusters requested.'

        cpp_param_doc['dataset'] = 'pointer to a data set stored in row major order'
        cpp_param_doc['clusters'] = 'number of cluster to compute'
        cpp_param_doc['result_centers'] = 'memory buffer where the output cluster centers are stored'
        cpp_param_doc['flann_params'] = 'generic flann parameters and index_params used to specify the kmeans tree parameters (branching factor, max number of iterations to use)'

        return_type = 'int'
        binding_argnames = ['dataset', 'rows', 'cols', 'clusters', 'result_centers',
                            'flann_params']
        optional_args = ['Distance d = Distance()']
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
        py_alias = 'nn_radius'
        py_args = 'query, radius, **kwargs'.split(', ')

    elif binding_name == 'find_nearest_neighbors_index':
        docstr = ut.codeblock(
            '''
            Searches for nearest neighbors using the index provided
            ''')
        return_doc = zero_success
        return_type = 'int'
        # optional_args = ['Distance d = Distance()']
        binding_argnames = ['index_ptr', 'testset', 'tcount', 'result_ids',
                            'dists', 'nn', 'flann_params', ]
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
        docstr = ut.codeblock(
            '''
            Builds an index and uses it to find nearest neighbors.
            ''')
        return_doc = zero_success

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

        py_alias = 'nn'
        py_args = ['pts', 'qpts', 'num_neighbors=1', '**kwargs']
        return_type = 'int'
        binding_argnames = ['dataset', 'rows', 'cols', 'testset', 'tcount',
                            'result_ids', 'dists', 'nn', 'flann_params']
        optional_args = ['Distance d = Distance()']
    elif binding_name == 'load_index':
        docstr = ut.codeblock(
            '''
            Loads a previously saved index from a file.
            ''')
        return_doc = 'index_ptr'
        cpp_param_doc['dataset'] = 'The dataset corresponding to the index'
        cpp_param_doc['filename'] = 'File to load the index from'
        c_source_part = ut.codeblock(
            r'''
            Index<Distance>* index = new Index<Distance>(Matrix<typename Distance::ElementType>(dataset,rows,cols), SavedIndexParams(filename), d);
            return index;
            '''
        )
        return_type = 'flann_index_t'
        binding_argnames = ['filename', 'dataset', 'rows', 'cols']
        optional_args = ['Distance d = Distance()']
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
        py_args = ['filename', 'pts']

    elif binding_name == 'save_index':
        docstr = ut.codeblock(
            '''
            Saves the index to a file. Only the index is saved into the file, the dataset corresponding to the index is not saved.
            ''')
        cpp_param_doc['index_ptr'] = 'The index that should be saved'
        cpp_param_doc['filename'] = 'The filename the index should be saved to'
        return_doc = 'Returns 0 on success, negative value on error'
        c_source_part = ut.codeblock(
            r'''
            Index<Distance>* index = (Index<Distance>*)index_ptr;
            index->save(filename);

            return 0;
            ''')
        return_type = 'int'
        binding_argnames = ['index_ptr', 'filename']
        py_alias = None
        py_args = None
        py_source = ut.codeblock(
            '''
            if self.__curindex is not None:
                flann.save_index[self.__curindex_type](
                    self.__curindex, c_char_p(to_bytes(filename)))
            ''')

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
        docstr = ut.codeblock(
            '''
            Deletes an index and releases the memory used by it.
            ''')
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
        cpp_param_doc['flann_params'] = 'generic flann params (only used to specify verbosity)'
        py_alias = 'delete_index'
        py_args = ['**kwargs']
    elif binding_name == 'get_point':
        docstr = ut.codeblock(
            '''
            Gets a point from a given index position.
            ''')
        return_doc = 'pointer to datapoint or NULL on miss'
        binding_argnames = ['index_ptr', 'point_id']
        cpp_param_doc['point_id'] = 'index of datapoint to get.'
        return_type = 'Distance::ElementType*'
    elif binding_name == 'flann_get_distance_order':
        docstr = ut.codeblock(
            '''
            * Gets the distance order in use throughout FLANN (only applicable if minkowski distance
            * is in use).
            '''
        )
        binding_argnames = []
        return_type = 'int'
    else:
        dictdef = {
            '_template_new': {
                'docstr': ut.codeblock(
                    '''
                    '''
                ),
                'binding_argnames': [],
                'return_type': 'int',
            },

            'flann_get_distance_type': {
                'docstr': ut.codeblock(
                    '''
                    '''
                ),
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

        if 'Params:*' in docstr and len(binding_argnames) > 0:
            param_docs = ut.dict_take(cpp_param_doc, binding_argnames)
            cpp_param_docblock = '\n'.join(['%s = %s' % (name, doc) for name, doc in zip(binding_argnames, param_docs)])
            docstr_cpp = docstr.replace('Params:*', 'Params:\n' + ut.indent(cpp_param_docblock, '    '))
        if '@Param*' in docstr and len(binding_argnames) > 0:
            param_docs = ut.dict_take(cpp_param_doc, binding_argnames)
            cpp_param_docblock = '\n'.join(['* @param %s %s' % (name, doc) for name, doc in zip(binding_argnames, param_docs)])
            docstr_cpp = docstr.replace('@Param*', ut.indent(cpp_param_docblock, ''))
        if return_doc is not None:
            param_docs = ut.dict_take(cpp_param_doc, binding_argnames)
            cpp_param_docblock = '\n'.join(['%s = %s' % (name, doc) for name, doc in zip(binding_argnames, param_docs)])
            docstr_cpp += '\n\n' + 'Params:\n' + ut.indent(cpp_param_docblock, '    ')
            docstr_cpp += '\n\n' + 'Returns: ' + return_doc

        if pydoc is None:
            docstr_py = docstr[:]
        else:
            docstr_py = pydoc[:]

        if py_args:
            py_param_doc = cpp_param_doc.copy()
            py_param_doc['pts'] = py_param_doc['dataset'].replace('pointer to ', '')
            py_param_doc['qpts'] = py_param_doc['testset'].replace('pointer to ', '') + ' (may be a single point)'
            py_param_doc['num_neighbors'] = py_param_doc['nn']
            py_param_doc['**kwargs'] = py_param_doc['flann_params']
            py_args_ = [a.split('=')[0] for a in py_args]
            param_docs = ut.dict_take(py_param_doc, py_args_, '')
            # py_types =
            py_param_docblock = '\n'.join(['%s: %s' % (name, doc) for name, doc in zip(py_args_, param_docs)])
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

    flann_cpp_code_fmtstr = ut.codeblock(
        r'''
        // {binding_name} BEGIN CPP BINDING
        template <typename Distance>
        {return_type} __flann_{binding_name}({templated_args})
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

    explicit_type_bindings_fmtstr = ut.codeblock(
        r'''
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

    # print('------')
    # print('flann_cpp_codeblock_fmtstr.format = %s' % (flann_cpp_codeblock_fmtstr,))
    try:
        flann_cpp_codeblock = flann_cpp_codeblock_fmtstr.format(
            cpp_binding_name=cpp_binding_name,
            minkowski_option=minkowski_option,
            binding_name=binding_name,
            templated_args=templated_args, callargs=callargs,
            T_typed_sigargs_cpp=T_typed_sigargs_cpp,
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
