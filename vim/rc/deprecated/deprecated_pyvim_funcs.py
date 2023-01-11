def vim_grep(pat, mode='normal', hashid=None):
    import vim
    import utool as ut
    import ubelt as ub
    ut.ENABLE_COLORS = False
    ut.util_str.ENABLE_COLORS = False
    if hashid is None:
        hashid = ub.hash_data(pat)
    print('Grepping for pattern = %r' % (pat,))
    import os

    def _grep_dpath(dpath):
        grep_tup = ut.grep([pat], dpath_list=[dpath],
                           exclude_patterns=['*.pyc'], verbose=False)
        reflags = 0
        (found_fpath_list, found_lines_list, found_lxs_list) = grep_tup
        regex_list = [pat]
        _exprs_flags = [ut.util_regex.extend_regex2(expr, reflags)
                        for expr in regex_list]
        extended_regex_list = ut.take_column(_exprs_flags, 0)
        grep_result = ut.GrepResult(found_fpath_list, found_lines_list,
                                    found_lxs_list, extended_regex_list,
                                    reflags=reflags)
        text = '\n'.join([
            'Greping Directory "{}"'.format(dpath),
            'tofind_list={}'.format(ub.repr2(extended_regex_list)),
            grep_result.make_resultstr(colored=False),
            '=============',
            'found_fpath_list = {}'.format(ub.repr2(found_fpath_list, nl=1))
        ])
        return text

    if mode == 'normal':
        text = _grep_dpath(os.getcwd())
    elif mode == 'repo':
        for path in ut.ancestor_paths(limit={'~/code', '~'}):
            if exists(join(path, '.git')):
                break
        text = _grep_dpath(path)
    elif mode == 'project':
        msg_list = ut.grep_projects([pat], verbose=False, colored=False)
        text = '\n'.join(msg_list)
    else:
        raise KeyError('unknown pyvim_funcs.vim_grep mode={}'.format(mode))

    fname = 'tmp_grep_' + hashid + '.txt'
    dpath = ub.ensure_app_cache_dir('pyvim_funcs')
    fpath = join(dpath, fname)

    # Display the text in a new vim split
    open_fpath(fpath=fpath, mode='new')
    overwrite_text(text)
    vim.command(":exec ':w'")
