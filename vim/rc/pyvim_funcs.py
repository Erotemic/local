from os.path import expanduser


def find_pyfunc_near_cursor():
    import vim
    # Get text posision
    (row, col) = vim.current.window.cursor
    searchlines = []  # for debugging

    # Janky way to find function name
    for ix in range(50):
        searchline = vim.current.buffer[row - ix]
        cleanline = searchline.strip(' ')
        searchlines.append(cleanline)
        if cleanline.startswith('def '):  # and cleanline.endswith(':'):
            rparen_pos = cleanline.find('(')
            if rparen_pos > 0:
                funcname = cleanline[4:rparen_pos].strip(' ')
                # Found a valid function name
                return funcname,  searchlines
    return None, searchlines


def auto_docstr(tmp=False):
    from utool import util_dev
    from utool import util_str
    import vim
    import imp
    imp.reload(util_dev)
    imp.reload(util_str)

    modname = None
    funcname = None
    flag = False
    dbgtext = ''
    docstr = ''
    dbgmsg = ''

    try:
        funcname, searchlines = find_pyfunc_near_cursor()
        modname = get_current_modulename()

        if funcname is None:
            funcname = '[vimerr] UNKNOWN_FUNC'
            flag = True
        else:
            modname = modname
            # Text to insert into the current buffer
            docstr = util_dev.auto_docstr(modname, funcname, verbose=False)
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
        dbgtext += util_str.indentjoin(searchlines, '\n| ')
        dbgtext += '\nL----------------------'

    text = '\n'.join([docstr + dbgtext])
    return text


def get_current_modulename():
    """
    returns current module being edited
    """
    from utool  import util_path
    import imp
    import vim
    imp.reload(util_path)
    modname = util_path.get_absolute_import(vim.current.buffer.name)
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


def open_fpath_list(fpath_list, nsplits=2):
    import vim
    ix = 0
    if ix >= len(fpath_list):
        return
    vim.command(":exec ':tabe %s'" % expanduser(fpath_list[ix]))
    vim.command(":set nofoldenable")
    ix += 1

    if ix >= len(fpath_list):
        return
    vim.command(":exec ':vsplit %s'" % expanduser(fpath_list[ix]))
    vim.command(":set nofoldenable")
    ix += 1

    if nsplits == 3:
        if ix >= len(fpath_list):
            return
        vim.command(":exec ':vsplit %s'" % expanduser(fpath_list[ix]))
        vim.command(":set nofoldenable")
        ix += 1

    for ix in xrange(ix, ix + 3):
        if ix >= len(fpath_list):
            return
        vim.command(":exec ':split %s'" % expanduser(fpath_list[ix]))
        vim.command(":set nofoldenable")

    vim.command(":exec ':wincmd l'")
    for ix in xrange(ix, ix + 3):
        if ix >= len(fpath_list):
            return
        vim.command(":exec ':split %s'" % expanduser(fpath_list[ix]))
        vim.command(":set nofoldenable")
