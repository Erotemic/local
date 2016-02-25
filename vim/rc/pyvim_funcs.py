# -*- coding: utf-8 -*-
"""
Called by ~/local/vim/rc/custom_misc_functions.vim

References:
    # The vim python module documentation
    http://vimdoc.sourceforge.net/htmldoc/if_pyth.html

ToLookAt:
    https://github.com/ivanov/ipython-vimception

FIXME:
    the indexing is messed up because some places row2 means the last line,
    instead of the last line you dont want
"""
#from __future__ import absolute_import, division, print_function, unicode_literals
from os.path import expanduser
import sys


def pyrun_fuzzyfont(request):
    """
    Sets a font from an index or a string
    """
    import vim
    import sys
    import six
    from operator import itemgetter

    def vimprint(message):
        #print('message = %r' % (message,))
        # this doesnt even work #vim.command(':silent !echom %r' % message)
        # vim.command(':echom %r' % message)
        pass
    vimprint('--- Called Fuzyzfont ---')

    #print('request = %r' % (request,))
    win32_fonts = [
        r'Mono_Dyslexic:h10:cANSI',
        r'Inconsolata:h10',
        r'monofur:h11',
        #r'Mono\ Dyslexic:h10',
        #r'Inconsolata:h11',
        #r'Source_Code_Pro:h11:cANSI',
        #r'peep:h11:cOEM',
        #r'Consolas',
        #r'Liberation Mono',
        #r'Lucida_Console:h10',
        #r'Fixedsys',
        #r'Courier:h10:cANSI',
        #r'Courier New',
        #r'DejaVu Sans Mono',
    ]
    #win32_alts = {
    #    'monodyslexic': [r'Mono_Dyslexic:h10:cANSI']
    #}
    linux_fonts = [
        r'Inconsolata\ Medium\ 9',
        r'Inconsolata\ Medium\ 11',
        r'MonoDyslexic\ 9.4',
        r'OpenDyslexicMono\ 10',
        r'monofur\ 11',
    ]
    #linux_extended = [
    #    r'MonoDyslexic\ 10',
    #    r'Inconsolata\ Medium\ 10',
    #    r'Courier\ New\ 11',
    #    #r'OpenDyslexic\ 10',
    #    #r'Neep\ 11',
    #    #r'Nimbus\ Mono\ L\ 11',
    #    r'Ubuntu\ Mono\ 9',
    #    r'Neep\ Alt\ Medium\ Semi-Condensed\ 11'
    #    r'White\ Rabbit\ 10',
    #]
    #linux_fonts = sorted(linux_fonts + linux_extended)
    if sys.platform.startswith('win32'):
        known_fonts = win32_fonts
    else:
        known_fonts = linux_fonts

    vimprint('numfonts=%r' % (len(known_fonts)))
    vimprint('request=%r %r' % (type(request), request))

    int_str = map(str, range(0, 10))
    try:
        is_integer_str = all([_ in int_str for _ in request])
    except TypeError:
        is_integer_str = False
    if isinstance(request, six.string_types) and not is_integer_str:
        # Calcualate edit distance to each known font
        try:
            import Levenshtein  # Edit distance algorithm
        except ImportError:
            vim.command(":echom 'error no python module Levenshtein"
                        "(pip install python-levenshtein)'")
        else:
            edit_distance = Levenshtein.distance
            known_dists = [edit_distance(known.lower(), request.lower())
                            for known in known_fonts]

            # Pick the minimum distance
            min_index = min(enumerate(known_dists), key=itemgetter(1))[0]
            fontindex = min_index
    else:
        fontindex = int(request) % len(known_fonts)

    fontstr = known_fonts[fontindex]
    # Set as current font
    vimprint('fontindex=%r fontstr=%r' % (fontindex, fontstr))
    vim.command('set gfn=' + fontstr)
    vimprint('--- /Called Fuzyzfont ---')


def get_expr_at_cursor():
    """ returns the word highlighted by the curor """
    import vim
    buf = vim.current.buffer
    (row, col) = vim.current.window.cursor
    line = buf[row - 1]  # Original end of the file
    nonword_chars = ' \t\n\r[](){}:;,"\'\\/='
    word = get_word_in_line_at_col(line, col, nonword_chars)
    return word


def get_line_at_cursor():
    import vim
    buf = vim.current.buffer
    (row, col) = vim.current.window.cursor
    line = buf[row - 1]  # Original end of the file
    return line


def get_word_at_cursor(url_ok=False):
    """ returns the word highlighted by the curor """
    import vim
    buf = vim.current.buffer
    (row, col) = vim.current.window.cursor
    line = buf[row - 1]  # Original end of the file
    if url_ok:
        nonword_chars = ' \t\n\r{},"\'\\'
    else:
        nonword_chars = ' \t\n\r[](){}:;.,"\'\\/'
    word = get_word_in_line_at_col(line, col, nonword_chars)
    return word


def get_word_in_line_at_col(line, col, nonword_chars=' \t\n\r[](){}:;.,"\'\\/'):
    r"""
    Args:
        line (?):
        col (?):

    Returns:
        ndarray[uint8_t, ndim=1]: word -  aggregate descriptor cluster center

    CommandLine:
        python  ~/local/vim/rc/pyvim_funcs.py --test-get_word_in_line_at_col

    Example:
        >>> # DISABLE_DOCTEST
        >>> from pyvim_funcs import *  # NOQA
        >>> line = 'myvar.foo = yourvar.foobar'
        >>> line = 'def loadfunc(self):'
        >>> col = 6
        >>> nonword_chars=' \t\n\r[](){}:;.,"\'\\/'
        >>> word = get_word_in_line_at_col(line, col, nonword_chars)
        >>> result = ('word = %r' % (word,))
        >>> print(result)
    """
    lpos = col
    rpos = col
    while lpos > 0:
        if line[lpos] in nonword_chars:
            lpos += 1
            break
        lpos -= 1
    while rpos < len(line):
        if line[rpos] in nonword_chars:
            break
        rpos += 1
    word = line[lpos:rpos]
    return word


# --- Find file markers

def find_pyfunc_above_cursor():
    import vim
    import utool as ut
    ut.util_dbg.COLORED_EXCEPTIONS = False
    # Get text posision
    (row, col) = vim.current.window.cursor
    line_list = vim.current.buffer
    funcname, searchlines = ut.find_pyfunc_above_row(line_list, row, True)
    return funcname, searchlines


def is_paragraph_end(line_):
    # Hack, par_marker_list should be an argument
    striped_line = line_.strip()
    isblank = striped_line == ''
    if isblank:
        return True
    par_marker_list = [
        #'\\noindent',
        '\\begin{equation}',
        '\\end{equation}',
        '% ---',
    ]
    return any(striped_line.startswith(marker)
                 for marker in par_marker_list)


def find_paragraph_end(row_, direction=1):
    """
    returns the line that a paragraph ends on in some direction

    TODO Rectify with ut.find_block_end
    """
    import vim
    line_list = vim.current.buffer
    line_ = line_list[row_ - 1]
    if (row_ == 0 or row_ == len(line_list) - 1):
        return row_
    if is_paragraph_end(line_):
        return row_
    while True:
        if (row_ == -1 or row_ == len(line_list)):
            break
        line_ = line_list[row_ - 1]
        if is_paragraph_end(line_):
            break
        row_ += direction
    row_ -= direction
    return row_


def get_paragraph_line_range_at_cursor():
    """
    Fixme row2 should be the first row you do not want
    """
    # Get cursor position
    import vim
    (row, col) = vim.current.window.cursor
    row1 = find_paragraph_end(row, -1)
    row2 = find_paragraph_end(row, +1)
    return row1, row2


# --- Text extractors


def get_selected_text(select_at_cursor=False):
    """ make sure the vim function calling this has a range after ()

    Currently used by <ctrl+g>

    References:
        http://stackoverflow.com/questions/18165973/vim-obtain-string-between-visual-selection-range-with-python

    SeeAlso:
        ~/local/vim/rc/custom_misc_functions.vim

    Test paragraph.
    Far out in the uncharted backwaters of the unfashionable end of the western
    spiral arm of the Galaxy lies a small unregarded yellow sun. Orbiting this at a
    distance of roughly ninety-two million miles is an utterly insignificant little
    blue green planet whose ape-descended life forms are so amazingly primitive
    that they still think digital watches are a pretty neat idea.
    % ---
    one. two three. four.

    """
    import vim
    buf = vim.current.buffer
    (lnum1, col1) = buf.mark('<')
    (lnum2, col2) = buf.mark('>')
    text = get_text_between_lines(lnum1, lnum2, col1, col2)
    return text


def get_text_between_lines(lnum1, lnum2, col1=0, col2=sys.maxint - 1):
    import vim
    lines = vim.eval('getline({}, {})'.format(lnum1, lnum2))
    try:
        if len(lines) == 0:
            pass
        elif len(lines) == 1:
            lines[0] = lines[0][col1:col2 + 1]
        else:
            lines[0] = lines[0][col1:]
            lines[-1] = lines[-1][:col2 + 1]
        text = '\n'.join(lines)
    except Exception:
        import utool as ut
        ut.util_dbg.COLORED_EXCEPTIONS = False
        print(ut.list_str(lines))
        raise
    return text


def get_codelines_around_buffer(rows_before=0, rows_after=10):
    import vim
    (row, col) = vim.current.window.cursor
    codelines = [vim.current.buffer[row - ix] for ix in range(rows_before, rows_after)]
    return codelines


# --- INSERT TEXT CODE


def insert_codeblock_over_selection(text):
    import vim
    buf = vim.current.buffer
    # These are probably 1 based
    (row1, col1) = buf.mark('<')
    (row2, col2) = buf.mark('>')
    insert_codeblock_between_lines(text, row1, row2)
    #buffer_tail = vim.current.buffer[row2:]  # Original end of the file
    #lines = [line.encode('utf-8') for line in text.split('\n')]
    #new_tail  = lines + buffer_tail
    #del(vim.current.buffer[row1 - 1:])  # delete old data
    #vim.current.buffer.append(new_tail)  # append new data


def insert_codeblock_between_lines(text, row1, row2):
    import vim
    buffer_tail = vim.current.buffer[row2:]  # Original end of the file
    lines = [line.encode('utf-8') for line in text.split('\n')]
    new_tail  = lines + buffer_tail
    del(vim.current.buffer[row1 - 1:])  # delete old data
    vim.current.buffer.append(new_tail)  # append new data
    # TODO:
    #ut.insert_block_between_lines(text, row1, row2, vim.buffer, inplace=True)


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


def append_text(text):
    import vim
    lines = text.split('\n')
    vim.current.buffer.append(lines)


def overwrite_text(text):
    import vim
    lines = text.split('\n')
    del (vim.current.buffer[:])
    vim.current.buffer.append(lines)


# --- Docstr Stuff


def is_module_pythonfile():
    from os.path import splitext
    import vim
    modpath = vim.current.buffer.name
    ext = splitext(modpath)[1]
    ispyfile = ext == '.py'
    verbose = False
    if verbose:
        print('is_module_pythonfile?')
        print('  * modpath = %r' % (modpath,))
        print('  * ext = %r' % (ext,))
        print('  * ispyfile = %r' % (ispyfile,))
    return ispyfile


def get_current_modulename():
    """
    returns current module being edited

    buffer_name = ut.truepath('~/local/vim/rc/pyvim_funcs.py')
    """
    import vim
    from os.path import dirname
    import utool as ut
    ut.util_dbg.COLORED_EXCEPTIONS = False
    #ut.rrrr(verbose=False)
    buffer_name = vim.current.buffer.name
    modname = ut.get_modname_from_modpath(buffer_name)
    moddir = dirname(buffer_name)
    return modname, moddir


def auto_docstr(**kwargs):
    import imp
    import utool as ut
    ut.util_dbg.COLORED_EXCEPTIONS = False
    try:
        print("RELOADING UTOOL via imp")
        imp.reload(ut)
        imp.reload(ut._internal.meta_util_arg)
    except Exception as ex:
        print("... errored")
        pass
    print("RELOADING UTOOL via rrrr")
    ut.rrrr(verbose=0)
    imp.reload(ut)
    import vim

    modname = None
    funcname = None
    flag = False
    dbgtext = ''
    docstr = ''
    dbgmsg = ''

    try:
        funcname, searchlines = find_pyfunc_above_cursor()
        modname, moddir = get_current_modulename()

        if funcname is None:
            funcname = '[vimerr] UNKNOWN_FUNC: funcname is None'
            flag = True
        else:
            # Text to insert into the current buffer
            verbose = True
            autodockw = dict(verbose=verbose)
            autodockw.update(kwargs)
            docstr = ut.auto_docstr(modname, funcname, moddir=moddir, **autodockw)
            #if docstr.find('unexpected indent') > 0:
            #    docstr = funcname + ' ' + docstr
            if docstr[:].strip() == 'error':
                flag = True
    except vim.error as ex:
        dbgmsg = 'vim_error: ' + str(ex)
        flag = False
    except Exception as ex:
        dbgmsg = 'exception(%r): %s' % (type(ex), str(ex))
        ut.printex(ex, tb=True)
        flag = False

    if flag:
        dbgtext += '\n+======================'
        dbgtext += '\n| --- DEBUG OUTPUT --- '
        if len(dbgmsg) > 0:
            dbgtext += '\n| Message: '
            dbgtext += dbgmsg
        dbgtext += '\n+----------------------'
        dbgtext += '\n| InsertDoctstr(modname=%r, funcname=%r' % (modname, funcname)
        pycmd = ('import ut; print(ut.auto_docstr(%r, %r)))' % (modname, funcname))
        pycmd = pycmd.replace('\'', '\\"')
        dbgtext += '\n| python -c "%s"' % (pycmd,)
        dbgtext += '\n+----------------------'
        dbgtext += '\n+searchlines = '
        dbgtext += ut.indentjoin(searchlines, '\n| ')
        dbgtext += '\nL----------------------'
    elif len(dbgmsg) > 0:
        dbgtext += '\n| Message: '
        dbgtext += dbgmsg

    text = '\n'.join([docstr + dbgtext])

    if text == '':
        print('No Text! For some reason flag=%r' % (flag,))
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


def open_fpath(fpath, mode='e'):
    vim_fpath_cmd(mode, fpath)


def open_fpath_list(fpath_list, num_hsplits=2):
    """
    Very hacky function to nicely open a bunch of files
    Not well tested

    num_hsplits is for horizonatal splits
    """
    import vim
    from six.moves import range

    index = 0
    try:
        assert index < len(fpath_list)
        # First file opens new tab
        vim_fpath_cmd('tabe', fpath_list[index])
        index += 1

        # Second file opens a vsplit
        assert index < len(fpath_list)
        vim_fpath_cmd('vsplit', fpath_list[index])
        index += 1

        if num_hsplits == 3:
            assert index < len(fpath_list)
            vim_fpath_cmd('vsplit', fpath_list[index])
            index += 1

        # The next 3 splits are horizontal splits
        for index in range(index, index + 3):
            assert index < len(fpath_list)
            vim_fpath_cmd('split', fpath_list[index])

        # Move to the left screen
        vim.command(":exec ':wincmd l'")

        # Continue doing horizontal splits
        for index in range(index, index + 3):
            assert index < len(fpath_list)
            vim_fpath_cmd('split', fpath_list[index])
    except AssertionError:
        pass
    if index < len(fpath_list):
        print('WARNING: Too many files specified')
        print('Can only handle %d' % index)


def vim_grep_project(pat, hashid=None):
    import vim
    import utool as ut
    if hashid is None:
        hashid = ut.hashstr27(pat)
    print('Grepping for pattern = %r' % (pat,))
    msg_list = ut.grep_projects([pat], verbose=False, colored=False)
    fname = 'tmp_grep_' + hashid + '.txt'
    dpath = ut.get_app_resource_dir('utool')
    fpath = ut.unixjoin(dpath, fname)
    #pyvim_funcs.vim_fpath_cmd('split', fpath)
    vim_fpath_cmd('new', fpath)
    text = '\n'.join(msg_list)
    overwrite_text(text)
    vim.command(":exec ':w'")


if __name__ == '__main__':
    """
    CommandLine:
        python -m pyvim_funcs
        python -m pyvim_funcs --allexamples
        python -m pyvim_funcs --allexamples --noface --nosrc
    """
    import multiprocessing
    multiprocessing.freeze_support()  # for win32
    import utool as ut  # NOQA
    ut.util_dbg.COLORED_EXCEPTIONS = False
    ut.doctest_funcs()
