from os.path import expanduser


def parse_callname(searchline, sentinal='def '):
    rparen_pos = searchline.find('(')
    if rparen_pos > 0:
        callname = searchline[len(sentinal):rparen_pos].strip(' ')
        return callname
    return None


def find_pattern_above_row(pattern, line_list, row, maxIter=50):
    import re
    # Janky way to find function name
    ix = 0
    while True:
        pos = row - ix
        if maxIter is not None and ix > maxIter:
            break
        if pos < 0:
            break
            raise AssertionError('end of buffer')
        searchline = line_list[pos]
        if re.match(pattern, searchline) is not None:
            return searchline, pos
        ix += 1


def find_pyclass_above_row(line_list, row):
    # Get text posision
    pattern = '^class [a-zA-Z_]'
    classline, classpos = find_pattern_above_row(pattern, line_list, row, maxIter=None)
    return classline, classpos


def find_pyfunc_above_row(line_list, row):
    """
    >>> import utool
    >>> fpath = utool.truepath('~/code/ibeis/ibeis/control/IBEISControl.py')
    >>> line_list = utool.read_from(fpath, aslines=True)
    >>> row = 200
    >>> pyfunc, searchline = find_pyfunc_above_row(line_list, row)
    """
    searchlines = []  # for debugging
    funcname = None
    # Janky way to find function name
    func_sentinal   = 'def '
    method_sentinal = '    def '
    for ix in range(50):
        func_pos = row - ix
        searchline = line_list[func_pos]
        cleanline = searchline.strip(' ')
        searchlines.append(cleanline)
        if searchline.startswith(func_sentinal):  # and cleanline.endswith(':'):
            # Found a valid function name
            funcname = parse_callname(searchline, func_sentinal)
            if funcname is not None:
                break
        if searchline.startswith(method_sentinal):  # and cleanline.endswith(':'):
            # Found a valid function name
            funcname = parse_callname(searchline, method_sentinal)
            if funcname is not None:
                classline, classpos = find_pyclass_above_row(line_list, func_pos)
                classname = parse_callname(classline, 'class ')
                if classname is not None:
                    funcname = '.'.join([classname, funcname])
                    break
                else:
                    funcname = None
    return funcname, searchlines


def find_pyfunc_above_cursor():
    import vim
    # Get text posision
    (row, col) = vim.current.window.cursor
    line_list = vim.current.buffer
    return find_pyfunc_above_row(line_list, row)


def get_codelines_around_buffer(rows_before=0, rows_after=10):
    import vim
    (row, col) = vim.current.window.cursor
    codelines = [vim.current.buffer[row - ix] for ix in range(rows_before, rows_after)]
    return codelines


def is_module_pythonfile():
    from os.path import splitext
    import vim
    modpath = vim.current.buffer.name
    ext = splitext(modpath)[1]
    ispyfile = ext == '.py'
    #print(modname)
    #print(ext)
    return ispyfile


def get_current_modulename():
    """
    returns current module being edited
    """
    import utool as ut
    ut.rrrr(True)
    import vim
    modname = ut.get_modname_from_modpath(vim.current.buffer.name)
    return modname


def insert_codeblock_at_cursor(text):
    """
    Inserts code into a vim buffer
    """
    import vim
    (row, col) = vim.current.window.cursor
    lines = [line.encode('utf-8') for line in text.split('\n')]
    buffer_tail = vim.current.buffer[row:]  # Original end of the file
    new_tail = lines + buffer_tail  # Prepend our data
    del(vim.current.buffer[row:])  # delete old data
    vim.current.buffer.append(new_tail)  # append new data


def auto_docstr():
    import imp
    import utool
    imp.reload(utool)
    utool.rrrr(verbose=False)
    import vim

    modname = None
    funcname = None
    flag = False
    dbgtext = ''
    docstr = ''
    dbgmsg = ''

    try:
        funcname, searchlines = find_pyfunc_above_cursor()
        modname = get_current_modulename()

        if funcname is None:
            funcname = '[vimerr] UNKNOWN_FUNC: funcname is None'
            flag = True
        else:
            modname = modname
            # Text to insert into the current buffer
            docstr = utool.auto_docstr(modname, funcname, verbose=False)
            #if docstr.find('unexpected indent') > 0:
            #    docstr = funcname + ' ' + docstr
            if docstr[:].strip() == 'error':
                flag = True
    except vim.error as ex:
        dbgmsg = str(ex)
        flag = False
    except Exception as ex:
        dbgmsg = str(ex)
        flag = False

    if flag:
        dbgtext += '\n+======================'
        dbgtext += '\n| --- DEBUG OUTPUT --- '
        if len(dbgmsg) > 0:
            dbgtext += '\n| Message: '
            dbgtext += dbgmsg
        dbgtext += '\n+----------------------'
        dbgtext += '\n| InsertDoctstr(modname=%r, funcname=%r' % (modname, funcname)
        dbgtext += '\n+----------------------'
        dbgtext += utool.indentjoin(searchlines, '\n| ')
        dbgtext += '\nL----------------------'

    text = '\n'.join([docstr + dbgtext])
    return text


def vim_fpath_cmd(cmd, fpath, nofoldenable=True):
    import vim
    vim.command(":exec ':{cmd} {fpath}'".format(cmd=cmd, fpath=expanduser(fpath)))
    if nofoldenable:
        vim.command(":set nofoldenable")


def ensure_normalmode():
    """
    References:
        http://stackoverflow.com/questions/14013294/vim-how-to-detect-the-mode-in-which-the-user-is-in-for-statusline
    """
    allmodes = {
        'n'  : 'Normal',
        'no' : 'NOperatorPending',
        'v'  : 'Visual',
        'V'  : 'VLine',
        #'^V' : 'VBlock',
        's'  : 'Select',
        'S'  : 'SLine',
        #'^S' : 'SBlock',
        'i'  : 'Insert',
        'R'  : 'Replace',
        'Rv' : 'VReplace',
        'c'  : 'Command',
        'cv' : 'VimEx',
        'ce' : 'Ex',
        'r'  : 'Prompt',
        'rm' : 'More',
        'r?' : 'Confirm',
        '!'  : 'Shell',
    }
    import vim
    current_mode_code = vim.eval('mode()')
    current_mode = allmodes.get(current_mode_code, current_mode_code)
    if current_mode == 'Normal':
        return
    else:
        print('current_mode_code = %r' % current_mode)
        print('current_mode = %r' % current_mode)
    #vim.command("ESC")


def open_fpath_list(fpath_list, nsplits=2):
    """
    Very hacky function to nicely open a bunch of files
    Not well tested
    """
    import vim
    ix = 0
    if ix >= len(fpath_list):
        return
    vim_fpath_cmd('tabe', fpath_list[ix])
    ix += 1

    if ix >= len(fpath_list):
        return
    vim_fpath_cmd('vsplit', fpath_list[ix])
    ix += 1

    if nsplits == 3:
        if ix >= len(fpath_list):
            return
        vim_fpath_cmd('vsplit', fpath_list[ix])
        ix += 1

    for ix in xrange(ix, ix + 3):
        if ix >= len(fpath_list):
            return
        vim_fpath_cmd('split', fpath_list[ix])

    vim.command(":exec ':wincmd l'")  # Move to the left screen
    for ix in xrange(ix, ix + 3):
        if ix >= len(fpath_list):
            return
        vim_fpath_cmd('split', fpath_list[ix])
