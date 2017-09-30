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
from __future__ import absolute_import, division, print_function, unicode_literals
from os.path import expanduser, exists, join, isdir
import sys
import re
import itertools as it


def get_bibtex_dict():
    import utool as ut
    # HACK: custom current bibtex file
    possible_bib_fpaths = [
        ut.truepath('./My_Library_clean.bib'),
        #ut.truepath('~/latex/crall-thesis-2017/My_Library_clean.bib'),
    ]

    bib_fpath = None
    for bib_fpath_ in possible_bib_fpaths:
        if exists(bib_fpath_):
            bib_fpath = bib_fpath_
            break

    if bib_fpath is None:
        raise Exception('cant find bibtex file')

    # import bibtexparser
    from bibtexparser import bparser
    parser = bparser.BibTexParser()
    parser.ignore_nonstandard_types = True
    bib_text = ut.read_from(bib_fpath)
    bibtex_db = parser.parse(bib_text)
    bibtex_dict = bibtex_db.get_entry_dict()

    return bibtex_dict


def available_fonts():
    win32_fonts = [
        r'Mono_Dyslexic:h10:cANSI',
        r'Inconsolata:h10',
        r'OpenDyslexicMono\ 10',
        # r'monofur:h11',
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
        # r'OpenDyslexicMono\ 10',
        r'FreeMono\ Bold\ 10',
        # r'monofur\ 11',
        # r'EversonMono',
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
    return known_fonts


def pyrun_fuzzyfont(request):
    """
    Sets a font from an index or a string
    """
    import vim
    import six
    from operator import itemgetter

    def vimprint(message):
        #print('message = %r' % (message,))
        # this doesnt even work #vim.command(':silent !echom %r' % message)
        # vim.command(':echom %r' % message)
        pass
    vimprint('--- Called Fuzyzfont ---')

    known_fonts = available_fonts()

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
    nonword_chars = ' \t\n\r[](){}:;,"\'\\/=$'
    word = get_word_in_line_at_col(line, col, nonword_chars)
    return word


def get_line_at_cursor():
    import vim
    buf = vim.current.buffer
    (row, col) = vim.current.window.cursor
    line = buf[row - 1]
    return line


def get_first_nonempty_line_after_cursor():
    import vim
    buf = vim.current.buffer
    (row, col) = vim.current.window.cursor
    for i in range(len(buf) - row):
        line = buf[row + i]
        if line:
            return line


def get_cursor_py_indent():
    """
    checks current and next line for indentation
    """
    import utool as ut
    # Check current line for cues
    curr_line = get_line_at_cursor()
    curr_indent = ut.get_minimum_indentation(curr_line)
    if curr_line is None:
        next_line = ''
    if curr_line.strip().endswith(':'):
        curr_indent += 4
    # Check next line for cues
    next_line = get_first_nonempty_line_after_cursor()
    if next_line is None:
        next_line = ''
    next_indent = ut.get_minimum_indentation(next_line)
    if next_indent <= curr_indent + 8:
        # hack for overindented lines
        min_indent = max(curr_indent, next_indent)
    else:
        min_indent = curr_indent
    indent = (' ' * min_indent)
    if curr_line.strip().startswith('>>>'):
        indent += '>>> '
    return indent


def get_word_at_cursor(url_ok=False):
    """ returns the word highlighted by the curor """
    import vim
    buf = vim.current.buffer
    (row, col) = vim.current.window.cursor
    line = buf[row - 1]  # Original end of the file
    if url_ok:
        nonword_chars_left = ' \t\n\r{},"\'\\'
        nonword_chars_right = nonword_chars_left
    else:
        nonword_chars_left  = ' \t\n\r[](){}:;,"\'\\/='
        nonword_chars_right = ' \t\n\r[](){}:;,."\'\\/='
    word = get_word_in_line_at_col(line, col,
                                   nonword_chars_left=nonword_chars_left,
                                   nonword_chars_right=nonword_chars_right)
    return word


def get_word_in_line_at_col(line, col,
                            nonword_chars_left=' \t\n\r[](){}:;,"\'\\/',
                            nonword_chars_right=None):
    r"""
    Args:
        line (?):
        col (?):

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
    if nonword_chars_right is None:
        nonword_chars_right = nonword_chars_left
    lpos = col
    rpos = col
    while lpos > 0:
        # Expand to the left
        if line[lpos] in nonword_chars_left:
            lpos += 1
            break
        lpos -= 1
    while rpos < len(line):
        # Expand to the right
        if line[rpos] in nonword_chars_right:
            break
        rpos += 1
    word = line[lpos:rpos]
    return word


# --- Find file markers


def find_pyclass_above_row(line_list, row):
    """ originally part of the vim plugin """
    # Get text posision
    pattern = '^class [a-zA-Z_]'
    classline, classpos = find_pattern_above_row(pattern, line_list, row, maxIter=None)
    return classline, classpos


def parse_callname(searchline, sentinal='def '):
    """
    Parses the function or class name from a signature line
    originally part of the vim plugin
    """
    rparen_pos = searchline.find('(')
    if rparen_pos > 0:
        callname = searchline[len(sentinal):rparen_pos].strip(' ')
        return callname
    return None


def find_pattern_above_row(pattern, line_list='current', row='current', maxIter=50):
    """
    searches a few lines above the curror until it **matches** a pattern
    """
    if row == 'current':
        import vim
        row = vim.current.window.cursor[0] - 1
        line_list = vim.current.buffer
    # Iterate until we match Janky way to find function name
    for ix in it.count(0):
        pos = row - ix
        if maxIter is not None and ix > maxIter:
            break
        if pos < 0:
            break
        searchline = line_list[pos]
        if re.match(pattern, searchline) is not None:
            return searchline, pos
    return None


def find_pyfunc_above_row(line_list, row, orclass=False):
    """
    originally part of the vim plugin

    CommandLine:
        python -m utool.util_inspect --test-find_pyfunc_above_row

    Example:
        >>> # ENABLE_DOCTEST
        >>> from utool.util_inspect import *  # NOQA
        >>> import utool as ut
        >>> func = find_pyfunc_above_row
        >>> fpath = meta_util_six.get_funcglobals(func)['__file__'].replace('.pyc', '.py')
        >>> line_list = ut.read_from(fpath, aslines=True)
        >>> row = meta_util_six.get_funccode(func).co_firstlineno + 1
        >>> pyfunc, searchline = find_pyfunc_above_row(line_list, row)
        >>> result = pyfunc
        >>> print(result)
        find_pyfunc_above_row

    Example:
        >>> # DISABLE_DOCTEST
        >>> from utool.util_inspect import *  # NOQA
        >>> import utool as ut
        >>> fpath = ut.util_inspect.__file__.replace('.pyc', '.py')
        >>> line_list = ut.read_from(fpath, aslines=True)
        >>> row = 1608
        >>> pyfunc, searchline = find_pyfunc_above_row(line_list, row, orclass=True)
        >>> result = pyfunc
        >>> print(result)
        find_pyfunc_above_row
    """
    import utool as ut
    searchlines = []  # for debugging
    funcname = None
    # Janky way to find function name
    func_sentinal   = 'def '
    method_sentinal = '    def '
    class_sentinal = 'class '
    for ix in range(200):
        func_pos = row - ix
        searchline = line_list[func_pos]
        searchline = ut.ensure_unicode(searchline)
        cleanline = searchline.strip(' ')
        searchlines.append(cleanline)
        if searchline.startswith(func_sentinal):  # and cleanline.endswith(':'):
            # Found a valid function name
            funcname = parse_callname(searchline, func_sentinal)
            if funcname is not None:
                break
        if orclass and searchline.startswith(class_sentinal):
            # Found a valid class name (as funcname)
            funcname = parse_callname(searchline, class_sentinal)
            if funcname is not None:
                break
        if searchline.startswith(method_sentinal):  # and cleanline.endswith(':'):
            # Found a valid function name
            funcname = parse_callname(searchline, method_sentinal)
            if funcname is not None:
                classline, classpos = find_pyclass_above_row(line_list, func_pos)
                classname = parse_callname(classline, class_sentinal)
                if classname is not None:
                    funcname = '.'.join([classname, funcname])
                    break
                else:
                    funcname = None
    return funcname, searchlines


def find_pyfunc_above_cursor():
    import vim
    import utool as ut
    ut.ENABLE_COLORS = False
    ut.util_str.ENABLE_COLORS = False
    ut.util_dbg.COLORED_EXCEPTIONS = False
    # Get text posision
    (row, col) = vim.current.window.cursor
    line_list = vim.current.buffer
    funcname, searchlines = find_pyfunc_above_row(line_list, row, True)
    return funcname, searchlines


def is_paragraph_end(line_):
    # Hack, par_marker_list should be an argument
    import utool as ut
    striped_line = ut.ensure_unicode(line_.strip())
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


def get_text_between_lines(lnum1, lnum2, col1=0, col2=sys.maxsize - 1):
    import vim
    lines = vim.eval('getline({}, {})'.format(lnum1, lnum2))
    import utool as ut
    lines = ut.ensure_unicode_strlist(lines)
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
        ut.ENABLE_COLORS = False
        ut.util_str.ENABLE_COLORS = False
        ut.util_dbg.COLORED_EXCEPTIONS = False
        print(ut.repr2(lines))
        raise
    return text


def get_codelines_around_buffer(rows_before=0, rows_after=10):
    import vim
    (row, col) = vim.current.window.cursor
    codelines = [vim.current.buffer[row - ix] for ix in range(rows_before, rows_after)]
    return codelines


# --- INSERT TEXT CODE


def move_cursor(row, col=0):
    import vim
    vim.command('cal cursor({},{})'.format(row, col))


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


class DummyVimBuffer(object):
    def __init__(self, _list):
        self._list = _list

    def __repr__(self):
        return repr(self._list)

    def __str__(self):
        return str(self._list)

    def __delitem__(self, idx):
        del self._list[idx]

    def __getitem__(self, idx):
        return self._list[idx]

    def append(self, item):
        return self._list.extend(item)


def dummy_import_vim():
    vim = ut.DynStruct()
    vim.current = ut.DynStruct()
    vim.current.window = ut.DynStruct()
    vim.current.window.cursor = (0, 0)
    vim.current.buffer = DummyVimBuffer([
        'line1',
        'line2',
        'line3',
    ])
    return vim


def _insert_codeblock(vim, text, pos):
    """
    vim = dummy_import_vim()
    text = 'foobar'
    pos = 0
    _insert_codeblock(vim, text, pos)
    print(vim.current.buffer)
    """
    lines = [line.encode('utf-8') for line in text.split('\n')]
    buffer_tail = vim.current.buffer[pos:]  # Original end of the file
    new_tail = lines + buffer_tail  # Prepend our data
    del(vim.current.buffer[pos:])  # delete old data
    print(type(vim.current.buffer))
    vim.current.buffer.append(new_tail)  # extend new data


def insert_codeblock_above_cursor(text):
    """
    Inserts code into a vim buffer
    """
    import vim
    (row, col) = vim.current.window.cursor
    pos = row - 1
    # Rows are 1 indexed?
    _insert_codeblock(vim, text, pos)


def insert_codeblock_under_cursor(text):
    """
    Inserts code into a vim buffer
    """
    import vim
    (row, col) = vim.current.window.cursor
    lines = [line.encode('utf-8') for line in text.split('\n')]
    buffer_tail = vim.current.buffer[row:]  # Original end of the file
    new_tail = lines + buffer_tail  # Prepend our data
    del(vim.current.buffer[row:])  # delete old data
    vim.current.buffer.append(new_tail)  # extend new data


def append_text(text):
    """ Appends to existing text in the current buffer with new text """
    import vim
    lines = text.split('\n')
    vim.current.buffer.append(lines)


def overwrite_text(text):
    """ Overwrites existing text in the current buffer with new text """
    import vim
    lines = text.split('\n')
    del (vim.current.buffer[:])
    vim.current.buffer.append(lines)


# --- Docstr Stuff


def get_current_fpath():
    import vim
    fpath = vim.current.buffer.name
    return fpath


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


def get_current_filetype():
    import vim
    # from os.path import splitext
    # modpath = vim.current.buffer.name
    # ext = splitext(modpath)[1]
    filetype = vim.eval('&ft')
    return filetype


def get_current_modulename():
    """
    returns current module being edited

    buffer_name = ut.truepath('~/local/vim/rc/pyvim_funcs.py')
    """
    import vim
    from os.path import dirname
    import utool as ut
    ut.ENABLE_COLORS = False
    ut.util_str.ENABLE_COLORS = False
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
    ut.ENABLE_COLORS = False
    ut.util_str.ENABLE_COLORS = False
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


def open_fpath(fpath, mode='e', nofoldenable=False):
    """
    Execs new splits / tabs / etc

    Weird this wont work with directories (on my machine):
        https://superuser.com/questions/1243344/vim-wont-split-open-a-directory-from-python-but-it-works-interactively

    Args:
        fpath : file path to open
        mode: how to open the new file
            (valid options: split, vsplit, tabe, e, new, ...)

    Ignore:
        ~/.bashrc
        ~/code
    """
    import vim
    fpath = expanduser(fpath)
    if not exists(fpath):
        print("FPATH DOES NOT EXIST")
    # command = '{cmd} {fpath}'.format(cmd=cmd, fpath=fpath)
    if isdir(fpath):
        # Hack around directory problem
        if mode.startswith('e'):
            command = ':Explore! {fpath}'.format(fpath=fpath)
        elif mode.startswith('sp'):
            command = ':Hexplore! {fpath}'.format(fpath=fpath)
        elif mode.startswith('vs'):
            command = ':Vexplore! {fpath}'.format(fpath=fpath)
        else:
            raise NotImplementedError('implement fpath cmd for me')
    else:
        command = ":exec ':{mode} {fpath}'".format(mode=mode, fpath=fpath)
    # print('command = {!r}\n'.format(command))
    vim.command(command)

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
        open_fpath(fpath_list[index], mode='tabe')
        index += 1

        # Second file opens a vsplit
        assert index < len(fpath_list)
        open_fpath(fpath=fpath_list[index], mode='vsplit')
        index += 1

        if num_hsplits == 3:
            assert index < len(fpath_list)
            open_fpath(fpath=fpath_list[index], mode='vsplit')
            index += 1

        # The next 3 splits are horizontal splits
        for index in range(index, index + 3):
            assert index < len(fpath_list)
            open_fpath(fpath=fpath_list[index], mode='split')

        # Move to the left screen
        vim.command(":exec ':wincmd l'")

        # Continue doing horizontal splits
        for index in range(index, index + 3):
            assert index < len(fpath_list)
            open_fpath(fpath=fpath_list[index], mode='split')
    except AssertionError:
        pass
    if index < len(fpath_list):
        print('WARNING: Too many files specified')
        print('Can only handle %d' % index)


def vim_grep(pat, mode='normal', hashid=None):
    import vim
    import utool as ut
    ut.ENABLE_COLORS = False
    ut.util_str.ENABLE_COLORS = False
    if hashid is None:
        hashid = ut.hash_data(pat)
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
            'tofind_list={}'.format(ut.repr2(extended_regex_list)),
            grep_result.make_resultstr(colored=False),
            '=============',
            'found_fpath_list = {}'.format(ut.repr2(found_fpath_list, nl=1))
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
    dpath = ut.ensure_app_cache_dir('pyvim_funcs')
    fpath = join(dpath, fname)

    # Display the text in a new vim split
    open_fpath(fpath=fpath, mode='new')
    overwrite_text(text)
    vim.command(":exec ':w'")


def vim_argv(defaults=None):
    import vim
    nargs = int(vim.eval('a:0'))
    argv = [vim.eval('a:{}'.format(i + 1)) for i in range(nargs)]
    if defaults is not None:
        # fill the remaining unspecified args with defaults
        n_remain = len(defaults) - len(argv)
        remain = defaults[-n_remain:]
        argv += remain
    return argv


def vim_popup_menu(options):
    """ http://stackoverflow.com/questions/13537521/custom-popup-menu-in-vim """
    import vim
    import utool as ut
    vim.command('echohl Title')
    vim.command("echo 'Code fragments:'")
    vim.command("echohl None")
    id_list = ut.chr_range(len(options), base='1')
    for id_, opt in zip(id_list, options):
        vim.command("echo '%s. %s'" % (id_, opt))
    vim.command("echo 'Enter the number of your choice '")
    choice = chr(int(vim.eval('getchar()')))
    print('choice = %r' % (choice,))
    try:
        chosen = options[int(choice) - 1]
    except TypeError:
        chosen = None
    print('chosen = %r' % (chosen,))
    return chosen


def find_and_open_path(path, mode='split', verbose=0):
    import utool as ut
    import os

    def try_open(path):
        # base = '/home/joncrall/code/VIAME/packages/kwiver/sprokit/src/bindings/python/sprokit/pipeline'
        # base = '/home'
        if exists(path):
            if verbose:
                print('EXISTS path = {!r}\n'.format(path))
            open_fpath(path, mode=mode)
            return True

    path = expanduser(path)
    if try_open(path):
        return

    # path = 'sprokit/pipeline/pipeline.h'
    # base = os.getcwd()
    # base = '/home/joncrall/code/VIAME/packages/kwiver/sprokit/src/bindings/python/sprokit/pipeline'

    if path.startswith('<') and path.endswith('>'):
        path = path[1:-1]
    if path.endswith(':'):
        path = path[:-1]
    if try_open(path):
        return

    # Search downwards for relative paths
    candidates = []
    if not os.path.isabs(path):
        limit = {'~', os.path.expanduser('~')}
        start = os.getcwd()
        candidates += list(ut.ancestor_paths(start, limit=limit))
    candidates += os.environ['PATH'].split(os.sep)
    result = ut.search_candidate_paths(candidates, [path], verbose=verbose)
    if result is not None:
        path = result

    current_fpath = get_current_fpath()
    if os.path.islink(current_fpath):
        newbase = os.path.dirname(os.path.realpath(current_fpath))
        resolved_path = os.path.join(newbase, path)
        if try_open(resolved_path):
            return

    if try_open(path):
        return
    else:
        filetype = get_current_filetype()
        if True or filetype in {'py', 'pyx'}:
            try:
                path = ut.get_modpath_from_modname(path)
                print('rectified module to path = {!r}'.format(path))
            except Exception as ex:
                if True or filetype in {'py', 'pyx'}:
                    print(ex)
                    return
            if try_open(path):
                return

        #vim.command('echoerr "Could not find path={}"'.format(path))
        print('Could not find path={}'.format(path))


def getvar(key, default=None, context='g'):
    """ gets the value of a vim variable and defaults if it does not exist """
    import vim
    varname = '{}:{}'.format(context, key)
    var_exists = int(vim.eval('exists("{}")'.format(varname)))
    if var_exists:
        value = vim.eval('get({}:, "{}")'.format(context, key))
    else:
        value = default
    return value


def wmctrl_terminal_pattern():
    # Make sure regexes are bash escaped
    import re
    terminal_pattern = getvar('vpy_terminal_pattern', default=None)
    if terminal_pattern is None:
        terminal_pattern = r'\|'.join([
            'terminal',
            re.escape('terminator.Terminator'),  # gtk3 terminator
            re.escape('x-terminal-emulator.X-terminal-emulator'),  # gtk2 terminator
            # other common terminal applications
            'tilix',
            'konsole',
            'rxvt',
            'terminology',
            'xterm',
            'tilda',
            'Yakuake',
        ])
        return terminal_pattern


def enter_text_in_terminal(text, return_to_vim=True):
    """
    Takes a block of text, copies it to the clipboard, pastes it into the most
    recently used terminal, presses enter (if needed) to run what presumably is
    a command or script, and then returns to vim.

    TODO:
        * User specified terminal pattern
        * User specified paste keypress
        * Allow usage from non-gui terminal vim.
            (ensure we can detect if we are running in a terminal and
             register our window as the active vim, and then paste into
             the second mru terminal)
    """
    # Build xdtool script

    terminal_pattern = wmctrl_terminal_pattern()

    # Sequence of key presses that will trigger a paste event
    paste_keypress = 'ctrl+shift+v'

    import utool as ut
    # Copy the text to the clipboard
    ut.copy_text_to_clipboard(text)

    doscript = [
        ('remember_window_id', 'ACTIVE_GVIM'),
        ('focus', terminal_pattern),
        ('key', paste_keypress),
        ('key', 'KP_Enter'),
    ]
    if '\n' in text:
        # Press enter twice for multiline texts
        doscript += [
            ('key', 'KP_Enter'),
        ]
    if return_to_vim:
        doscript += [
            ('focus_id', '$ACTIVE_GVIM'),
        ]
    # execute script
    ut.util_ubuntu.XCtrl.do(*doscript, sleeptime=.01)
    #file=debug_file , verbose=DEBUG)


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
    ut.ENABLE_COLORS = False
    ut.util_str.ENABLE_COLORS = False
    ut.util_dbg.COLORED_EXCEPTIONS = False
    ut.doctest_funcs()
