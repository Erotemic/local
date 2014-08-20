from os.path import expanduser


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
