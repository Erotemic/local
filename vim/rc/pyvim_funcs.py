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
from os.path import expanduser, exists, join, isdir, abspath
import sys
import os
import re
import itertools as it


try:
    import importlib
    reload = importlib.reload
except (AttributeError, ImportError):
    import imp
    reload = imp.reload


def get_bibtex_dict():
    import ubelt as ub
    # HACK: custom current bibtex file
    possible_bib_fpaths = [
        ub.truepath('./My_Library_clean.bib'),
        #ub.truepath('~/latex/crall-thesis-2017/My_Library_clean.bib'),
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
    bib_text = ub.readfrom(bib_fpath)
    bibtex_db = parser.parse(bib_text)
    bibtex_dict = bibtex_db.get_entry_dict()

    return bibtex_dict


def available_fonts():
    win32_fonts = [
        r'Inconsolata:h10',
        r'Mono_Dyslexic:h10:cANSI',
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


def get_indentation(line_):
    """
    returns the number of preceding spaces
    """
    return len(line_) - len(line_.lstrip())


def get_minimum_indentation(text):
    r"""
    returns the number of preceding spaces

    Args:
        text (str): unicode text

    Returns:
        int: indentation

    CommandLine:
        xdoctest -m utool.util_str --exec-get_minimum_indentation --show

    Example:
        >>> # ENABLE_DOCTEST
        >>> from utool.util_str import *  # NOQA
        >>> text = '    foo\n   bar'
        >>> result = get_minimum_indentation(text)
        >>> print(result)
        3
    """
    lines = text.split('\n')
    indentations = [get_indentation(line_)
                    for line_ in lines  if len(line_.strip()) > 0]
    if len(indentations) == 0:
        return 0
    return min(indentations)


def get_cursor_py_indent():
    """
    checks current and next line for indentation
    """
    # Check current line for cues
    curr_line = get_line_at_cursor()
    curr_indent = get_minimum_indentation(curr_line)
    if curr_line is None:
        next_line = ''
    if curr_line.strip().endswith(':'):
        curr_indent += 4
    # Check next line for cues
    next_line = get_first_nonempty_line_after_cursor()
    if next_line is None:
        next_line = ''
    next_indent = get_minimum_indentation(next_line)
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
        nonword_chars_left  = ' \t\n\r[](){}:;,"\'\\/=$*'
        nonword_chars_right = ' \t\n\r[](){}:;,"\'\\/=$*.'
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
    # Iterate until we match.
    # Janky way to find function / class name
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
        python ~/local/vim/rc/pyvim_funcs.py find_pyfunc_above_row

    Example:
        >>> import ubelt as ub
        >>> import six
        >>> func = find_pyfunc_above_row
        >>> fpath = six.get_function_globals(func)['__file__'].replace('.pyc', '.py')
        >>> line_list = ub.readfrom(fpath, aslines=True)
        >>> row = six.get_function_code(func).co_firstlineno + 1
        >>> funcname, searchlines, func_pos, foundline = find_pyfunc_above_row(line_list, row)
        >>> print(funcname)
        find_pyfunc_above_row
    """
    import ubelt as ub
    searchlines = []  # for debugging
    funcname = None
    # Janky way to find function name
    func_sentinal   = 'def '
    method_sentinal = '    def '
    class_sentinal = 'class '
    for ix in range(200):
        func_pos = row - ix
        searchline = line_list[func_pos]
        searchline = ub.ensure_unicode(searchline)
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
    foundline = searchline
    return funcname, searchlines, func_pos, foundline


def find_pyfunc_above_cursor():
    import vim
    # Get text posision
    (row, col) = vim.current.window.cursor
    line_list = vim.current.buffer
    funcname, searchlines, pos, foundline = find_pyfunc_above_row(line_list, row, True)
    return funcname, searchlines, pos, foundline


def is_paragraph_end(line_):
    # Hack, par_marker_list should be an argument
    import ubelt as ub
    striped_line = ub.ensure_unicode(line_.strip())
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
    import ubelt as ub
    lines = list(map(ub.ensure_unicode, lines))
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
        print(ub.repr2(lines))
        raise
    return text


def get_codelines_around_buffer(rows_before=0, rows_after=10):
    import vim
    (row, col) = vim.current.window.cursor
    codelines = [vim.current.buffer[row - ix] for ix in range(rows_before, rows_after)]
    return codelines


# --- INSERT TEXT CODE

def get_cursor_position():
    import vim
    (row, col) = vim.current.window.cursor
    return row, col


class CursorContext(object):
    """
    moves back to original position after context is done
    """
    def __init__(self, offset=0):
        self.pos = None
        self.offset = offset

    def __enter__(self):
        self.pos = get_cursor_position()
        return self

    def __exit__(self, *exc_info):
        row, col = self.pos
        row += self.offset
        move_cursor(row, col)


def close_matching_folds(pattern, search_range=None, limit=1):
    """
    Looks in a range of lines for a pattern and executes a close fold command
    anywhere that matches.

    Example:
        >>> import os, sys
        >>> sys.path.append(os.path.expanduser('~/local/vim/rc'))
        >>> import pyvim_funcs
        >>> pyvim_funcs.dummy_import_vim(pyvim_funcs.__file__)
        >>> import vim
        >>> #pyvim_funcs.close_matching_folds('def ')
    """
    import vim
    if isinstance(search_range, (tuple, list)):
        search_range = slice(*search_range)

    if search_range is not None:
        text = '\n'.join(vim.current.buffer[search_range])
        offset = search_range.start
    else:
        text = '\n'.join(vim.current.buffer)
        offset = 0

    flags = re.MULTILINE | re.DOTALL
    patre = re.compile(pattern, flags=flags)

    # The context will remember and reset the current cursor position
    # with CursorContext():
    for count, match in enumerate(patre.finditer(text)):
        if limit is not None and count >= limit:
            break
        # Find the matching line
        lineno = text[:match.start()].count('\n') + offset + 1
        # Move to the fold
        move_cursor(lineno)
        # close the fold
        try:
            vim.command(':foldclose')
        except vim.error:
            pass


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


def find_python_import_row():
    """
    Find lines where import block begins (after __future__)
    """
    in_comment = False
    import vim
    row = 0
    for row, line in enumerate(vim.current.buffer):
        if not in_comment:
            if line.strip().startswith('#'):
                pass
            elif line.strip().startswith('"""'):
                in_comment = '"'
            elif line.strip().startswith("''''"):
                in_comment = "'"
            elif line.startswith('from __future__'):
                pass
            elif line.startswith('import'):
                break
            elif line.startswith('from'):
                break
            else:
                break
        else:
            if line.strip().endswith(in_comment * 3):
                in_comment = False
    return row


def prepend_import_block(text):
    import vim
    row = find_python_import_row()
    # FIXME: doesnt work right when row=0
    buffer_tail = vim.current.buffer[row:]
    lines = [line.encode('utf-8') for line in text.split('\n')]
    print('lines = {!r}'.format(lines))
    new_tail  = lines + buffer_tail
    del(vim.current.buffer[row:])  # delete old data
    # vim's buffer __del__ method seems to not work when the slice is 0:None.
    # It should remove everything, but it seems that one item still exists
    # It seems we can never remove that last item, so we have to hack.
    hackaway_row0 = row == 0 and len(vim.current.buffer) == 1
    # print(len(vim.current.buffer))
    # print('vim.current.buffer = {!r}'.format(vim.current.buffer[:]))
    vim.current.buffer.append(new_tail)  # append new data
    if hackaway_row0:
        del vim.current.buffer[0]


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


def dummy_import_vim(fpath=None):
    if fpath is not None:
        fpath = abspath(expanduser(fpath))

    try:
        import vim
        dohack = False
    except ImportError:
        dohack = True
        vim = None

    if vim is not None:
        if getattr(vim, '__ishack__', False):
            if fpath != vim.current.buffer.name:
                dohack = True

    if dohack:
        import sys
        import utool as ut
        vim = ut.DynStruct()
        vim.__ishack__  = True
        vim.current = ut.DynStruct()
        vim.current.window = ut.DynStruct()
        vim.current.window.cursor = (0, 0)
        if fpath is None:
            lines = [
                'line1',
                'line2',
                'line3',
            ]
        else:
            lines = ut.readfrom(fpath).splitlines()
        vim.current.buffer = DummyVimBuffer(lines)
        vim.current.buffer.name = fpath
        # VERY HACKY
        sys.modules['vim'] = vim
    return vim


def _insert_codeblock(vim, text, pos):
    """
    Example:
        >>> import os, sys
        >>> sys.path.append(os.path.expanduser('~/local/vim/rc'))
        >>> from pyvim_funcs import *
        >>> from pyvim_funcs import _insert_codeblock
        >>> vim = dummy_import_vim()
        >>> text = 'foobar'
        >>> pos = 0
        >>> _insert_codeblock(vim, text, pos)
        >>> print(vim.current.buffer)
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

    buffer_name = ub.truepath('~/local/vim/rc/pyvim_funcs.py')
    """
    import vim
    import ubelt as ub
    buffer_name = vim.current.buffer.name
    modname = ub.modpath_to_modname(buffer_name)
    moddir, rel_modpath = ub.split_modpath(buffer_name)
    # moddir = dirname(buffer_name)
    return modname, moddir


def auto_cmdline():
    import ubelt as ub
    from xdoctest import static_analysis as static
    import vim
    # import imp
    # imp.reload(static)
    modname, moddir = get_current_modulename()
    funcname, searchlines, pos, foundline = find_pyfunc_above_cursor()
    if static.is_modname_importable(modname, exclude=['.']):
        text = ub.codeblock(
            '''
            CommandLine:
                xdoctest -m {modname} {funcname}
            ''').format(funcname=funcname, modname=modname)
    else:
        modpath = ub.compressuser(vim.current.buffer.name)
        text = ub.codeblock(
            '''
            CommandLine:
                xdoctest -m {modpath} {funcname}
            ''').format(funcname=funcname, modpath=modpath)

    def get_indent(line):
        """
        returns the preceding whitespace
        """
        n_whitespace = len(line) - len(line.lstrip())
        prefix = line[:n_whitespace]
        return prefix

    prefix = get_indent(foundline)

    text = ub.indent(text, prefix + '    ')
    return text


def auto_docstr(**kwargs):
    import ubelt as ub
    USE_UTOOL = False
    import imp
    if USE_UTOOL:
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

    def make_docstr_block(header, block):
        indented_block = '\n' + ub.indent(block)
        docstr_block = ''.join([header, ':', indented_block])
        return docstr_block

    def new_autodoc(modname, funcname, moddir=None, modpath=None):
        # get_indentation()  # TODO
        num_indent = 4

        command = 'xdoctest -m {modname} {funcname}'.format(
            **locals())
        docstr = make_docstr_block('CommandLine', command)

        docstr = ub.indent(docstr, ' ' * num_indent)
        return docstr

    try:
        funcname, searchlines, pos, foundline = find_pyfunc_above_cursor()
        modname, moddir = get_current_modulename()
        modpath = vim.current.buffer.name
        print('modpath = {!r}'.format(modpath))

        if funcname is None:
            funcname = '[vimerr] UNKNOWN_FUNC: funcname is None'
            flag = True
        else:
            # Text to insert into the current buffer
            verbose = True
            autodockw = dict(verbose=verbose)
            autodockw.update(kwargs)
            if USE_UTOOL:
                docstr = ut.auto_docstr(modname, funcname, moddir=moddir,
                                        modpath=modpath, **autodockw)
            else:
                docstr = new_autodoc(modname, funcname, moddir=moddir,
                                     modpath=modpath)
            #if docstr.find('unexpected indent') > 0:
            #    docstr = funcname + ' ' + docstr
            if docstr[:].strip() == 'error':
                flag = True
    except vim.error as ex:
        dbgmsg = 'vim_error: ' + str(ex)
        flag = False
    except Exception as ex:
        dbgmsg = 'exception(%r): %s' % (type(ex), str(ex))
        if USE_UTOOL:
            ut.printex(ex, tb=True)
        else:
            print(repr(ex))
        flag = False

    if flag:
        dbgtext += '\n+======================'
        dbgtext += '\n| --- DEBUG OUTPUT --- '
        if len(dbgmsg) > 0:
            dbgtext += '\n| Message: '
            dbgtext += dbgmsg
        dbgtext += '\n+----------------------'
        dbgtext += '\n| InsertDoctstr(modname=%r, funcname=%r' % (modname, funcname)
        if USE_UTOOL:
            pycmd = ('import ut; print(ut.auto_docstr(%r, %r, %r)))' % (modname, funcname, modpath))
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


def open_fpath(fpath, mode='e', nofoldenable=False, verbose=0):
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

    if verbose:
        print('command = {!r}\n'.format(command))

    try:
        vim.command(command)
    except Exception as ex:
        print('FAILED TO OPEN PATH')
        print('ex = {!r}'.format(ex))
        raise
        pass

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


def ancestor_paths(start=None, limit={}):
    """
    All paths above you
    """
    limit = {expanduser(p) for p in limit}.union(set(limit))
    if start is None:
        start = os.getcwd()
    path = start
    prev = None
    while path != prev and prev not in limit:
        yield path
        prev = path
        path = os.path.dirname(path)


def search_candidate_paths(candidate_path_list, candidate_name_list=None,
                           priority_paths=None, required_subpaths=[],
                           verbose=None):
    """
    searches for existing paths that meed a requirement

    Args:
        candidate_path_list (list): list of paths to check. If
            candidate_name_list is specified this is the dpath list instead
        candidate_name_list (list): specifies several names to check
            (default = None)
        priority_paths (None): specifies paths to check first.
            Ignore candidate_name_list (default = None)
        required_subpaths (list): specified required directory structure
            (default = [])
        verbose (bool):  verbosity flag(default = True)

    Returns:
        str: return_path

    CommandLine:
        xdoctest -m utool.util_path --test-search_candidate_paths

    Example:
        >>> # DISABLE_DOCTEST
        >>> from utool.util_path import *  # NOQA
        >>> candidate_path_list = [ub.truepath('~/RPI/code/utool'),
        >>>                        ub.truepath('~/code/utool')]
        >>> candidate_name_list = None
        >>> required_subpaths = []
        >>> verbose = True
        >>> priority_paths = None
        >>> return_path = search_candidate_paths(candidate_path_list,
        >>>                                      candidate_name_list,
        >>>                                      priority_paths, required_subpaths,
        >>>                                      verbose)
        >>> result = ('return_path = %s' % (str(return_path),))
        >>> print(result)
    """
    if verbose is None:
        verbose = 1

    if verbose >= 1:
        print('[search_candidate_paths] Searching for candidate paths')

    if candidate_name_list is not None:
        candidate_path_list_ = [join(dpath, fname) for dpath, fname in
                                it.product(candidate_path_list,
                                           candidate_name_list)]
    else:
        candidate_path_list_ = candidate_path_list

    if priority_paths is not None:
        candidate_path_list_ = priority_paths + candidate_path_list_

    return_path = None
    for path in candidate_path_list_:
        if path is not None and exists(path):
            if verbose >= 2:
                print('[search_candidate_paths] Found candidate directory %r' % (path,))
                print('[search_candidate_paths] ... checking for approprate structure')
            # tomcat directory exists. Make sure it also contains a webapps dir
            subpath_list = [join(path, subpath) for subpath in required_subpaths]
            if all(exists(path_) for path_ in subpath_list):
                return_path = path
                if verbose >= 2:
                    print('[search_candidate_paths] Found acceptable path')
                return return_path
                break
    if verbose >= 1:
        print('[search_candidate_paths] Failed to find acceptable path')
    return return_path


def find_and_open_path(path, mode='split', verbose=0,
                       enable_python=True,
                       enable_url=True):
    """
    Fancy-Find. Does some magic to try and find the correct path.

    Currently supports:
        * well-formed absolute and relatiave paths
        * ill-formed relative paths when you are in a descendant directory
        * python modules that exist in the PYTHONPATH

    """
    import os

    def try_open(path):
        # base = '/home/joncrall/code/VIAME/packages/kwiver/sprokit/src/bindings/python/sprokit/pipeline'
        # base = '/home'
        if path and exists(path):
            if verbose:
                print('EXISTS path = {!r}\n'.format(path))
            open_fpath(path, mode=mode, verbose=verbose)
            return True

    def expand_module(path):
        # if True or filetype in {'py', 'pyx'}:
        # filetype = get_current_filetype()
        import sys
        sys.executable
        import ubelt as ub
        print('ub = {!r}'.format(ub))
        xdoc = ub.import_module_from_path('/home/joncrall/code/xdoctest/xdoctest')
        print('xdoc = {!r}'.format(xdoc))
        print('sys.executable = {!r}'.format(sys.executable))
        print('sys.prefix = {!r}'.format(sys.prefix))
        from xdoctest import static_analysis as static
        print('static = {!r}'.format(static))
        try:
            print('expand path = {!r}'.format(path))
            path = static.modname_to_modpath(path)
            print('expanded path = {!r}'.format(path))
            # print('rectified module to path = {!r}'.format(path))
        except Exception as ex:
            print('ex = {!r}'.format(ex))
            # if True or filetype in {'py', 'pyx'}:
            return None
        return path

    if enable_url:
        # https://github.com/Erotemic
        url = extract_url_embeding(path)
        if is_url(url):
            import webbrowser
            browser = webbrowser.open(url)
            # browser = webbrowser.get('google-chrome')
            browser.open(url)
            # ut.open_url_in_browser(url, 'google-chrome')
            return

    path = expanduser(path)
    if try_open(path):
        return

    if try_open(os.path.expandvars(path)):
        return

    # path = 'sprokit/pipeline/pipeline.h'
    # base = os.getcwd()
    # base = '/home/joncrall/code/VIAME/packages/kwiver/sprokit/src/bindings/python/sprokit/pipeline'

    if path.startswith('<') and path.endswith('>'):
        path = path[1:-1]
    if path.startswith('`') and path.endswith('`'):
        path = path[1:-1]
    if path.endswith(':'):
        path = path[:-1]
    path = expanduser(path)  # expand again in case a prefix was removed
    if try_open(path):
        return

    # Search downwards for relative paths
    candidates = []
    if not os.path.isabs(path):
        limit = {'~', os.path.expanduser('~')}
        start = os.getcwd()
        candidates += list(ancestor_paths(start, limit=limit))
    candidates += os.environ['PATH'].split(os.sep)
    result = search_candidate_paths(candidates, [path], verbose=verbose)
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
        print('enable_python = {!r}'.format(enable_python))
        if enable_python:
            pypath = expand_module(path)
            print('pypath = {!r}'.format(pypath))
            if try_open(pypath):
                return

        if re.match('--\w*=.*', path):
            # try and open if its a command line arg
            stripped_path = expanduser(re.sub('--\w*=', '', path))
            if try_open(stripped_path):
                return
        #vim.command('echoerr "Could not find path={}"'.format(path))
        print('Could not find path={!r}'.format(path))


def extract_url_embeding(word):
    """
    parse several common ways to embed url within a "word"
    """
    # rst url embedding
    if word.startswith('<') and word.endswith('>`_'):
        word = word[1:-3]
    # markdown url embedding
    if word.startswith('[') and word.endswith(')'):
        import parse
        pres = parse.parse('[{tag}]({ref})', word)
        if pres:
            word = pres.named['ref']
    return word


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


def keypress(keys):
    """
    Simulates keypress commands
    """
    import vim
    vim.command('call feedkeys("{}")'.format(keys))


def enter_text_in_terminal(text, return_to_vim=True):
    """
    Takes a block of text, copies it to the clipboard, pastes it into the most
    recently used terminal, presses enter (if needed) to run what presumably is
    a command or script, and then returns to vim.

    DEPRICATE:
        use vimtk instead

    TODO:
        * User specified terminal pattern
        * User specified paste keypress
        * Allow usage from non-gui terminal vim.
            (ensure we can detect if we are running in a terminal and
             register our window as the active vim, and then paste into
             the second mru terminal)
    """
    import utool as ut
    # Copy the text to the clipboard
    copy_text_to_clipboard(text)

    # Build xdtool script
    import sys
    if sys.platform.startswith('win32'):
        print('win32 cannot copy to terminal yet. Just copied to clipboard. '
              ' Needs AHK support for motion?')
        return

    terminal_pattern = wmctrl_terminal_pattern()

    # Sequence of key presses that will trigger a paste event
    paste_keypress = 'ctrl+shift+v'

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


def is_url(text):
    """ heuristic check if str is url formatted """
    return any([
        text.startswith('http://'),
        text.startswith('https://'),
        text.startswith('www.'),
        '.org/' in text,
        '.com/' in text,
    ])


def make_default_module_maintest(modpath, test_code=None, argv=None,
                                 force_full=False):
    """
    Args:
        modname (str):  module name

    Returns:
        str: text source code

    CommandLine:
        xdoctest -m utool.util_autogen --test-make_default_module_maintest

    References:
        http://legacy.python.org/dev/peps/pep-0338/

    Example:
        >>> import sys, ubelt as ub
        >>> sys.path.append(ub.truepath('~/local/vim/rc/'))
        >>> from pyvim_funcs import *
        >>> import pyvim_funcs
        >>> modpath = pyvim_funcs.__file__
        >>> argv = None
        >>> text = make_default_module_maintest(modpath)
        >>> print(text)
    """
    # if not use_modrun:
    #     if ub.WIN32:
    #         augpath = 'set PYTHONPATH=%PYTHONPATH%' + os.pathsep + moddir
    #     else:
    #         augpath = 'export PYTHONPATH=$PYTHONPATH' + os.pathsep + moddir
    #     cmdline = augpath + '\n' + cmdline
    import ubelt as ub
    from xdoctest import static_analysis as static

    modname = static.modpath_to_modname(modpath)
    moddir, rel_modpath = static.split_modpath(modpath)
    if not force_full:
        info = ub.cmd('python -c "import sys; print(sys.path)"')
        default_path = eval(info['out'], {})
        is_importable = static.is_modname_importable(modname, exclude=['.'],
                                                     sys_path=default_path)
    if not force_full and is_importable:
        cmdline = 'xdoctest -m ' + modname
    else:
        if ub.WIN32:
            modpath = ub.compressuser(modpath, home='%HOME%')
            cmdline = 'python -B ' + modpath.replace('\\', '/')
        else:
            modpath = ub.compressuser(modpath, home='~')
            cmdline = 'python ' + modpath

    if test_code is None:
        test_code = ub.codeblock(
            r'''
            import xdoctest
            xdoctest.doctest_module(__file__)
            ''')
        if argv is None:
            # argv = ['all']
            argv = []

    if argv is None:
        argv = []

    cmdline_ = ub.indent(cmdline + ' ' + ' '.join(argv), ' ' * 8).lstrip(' ')
    test_code = ub.indent(test_code, ' ' * 4).lstrip(' ')
    text = ub.codeblock(
        r'''
        if __name__ == '__main__':
            {rr}"""
            CommandLine:
                {cmdline_}
            """
            {test_code}
        '''
    ).format(cmdline_=cmdline_, test_code=test_code, rr='{r}')
    text = text.format(r='r' if '\\' in text else '')
    return text


def format_text_as_docstr(text):
    r"""
    CommandLine:
        python  ~/local/vim/rc/pyvim_funcs.py  --test-format_text_as_docstr

    Example:
        >>> # DISABLE_DOCTEST
        >>> from pyvim_funcs import *  # NOQA
        >>> text = testdata_text()
        >>> formated_text = format_text_as_docstr(text)
        >>> result = ('formated_text = \n%s' % (str(formated_text),))
        >>> print(result)
    """
    import re
    min_indent = get_minimum_indentation(text)
    indent_ =  ' ' * min_indent
    formated_text = re.sub('^' + indent_, '' + indent_ + '>>> ', text,
                           flags=re.MULTILINE)
    formated_text = re.sub('^$', '' + indent_ + '>>> #', formated_text,
                           flags=re.MULTILINE)
    return formated_text


def unformat_text_as_docstr(formated_text):
    r"""
    CommandLine:
        python  ~/local/vim/rc/pyvim_funcs.py  --test-unformat_text_as_docstr

    Example:
        >>> # DISABLE_DOCTEST
        >>> from pyvim_funcs import *  # NOQA
        >>> text = testdata_text()
        >>> formated_text = format_text_as_docstr(text)
        >>> unformated_text = unformat_text_as_docstr(formated_text)
        >>> result = ('unformated_text = \n%s' % (str(unformated_text),))
        >>> print(result)
    """
    import re
    min_indent = get_minimum_indentation(formated_text)
    indent_ =  ' ' * min_indent
    unformated_text = re.sub('^' + indent_ + '>>> ', '' + indent_,
                             formated_text, flags=re.MULTILINE)
    return unformated_text


def copy_text_to_clipboard(text):
    """
    Copies text to the clipboard

    CommandLine:
        pip install pyperclip
        sudo apt-get install xclip
        sudo apt-get install xsel

    References:
        http://stackoverflow.com/questions/11063458/python-script-to-copy-text-to-clipboard
        http://stackoverflow.com/questions/579687/how-do-i-copy-a-string-to-the-clipboard-on-windows-using-python

    Ignore:
        import pyperclip
        # Qt is by far the fastest, followed by xsel, and then xclip
        #
        backend_order = ['xclip', 'xsel', 'qt', 'gtk']
        backend_order = ['qt', 'xsel', 'xclip', 'gtk']
        for be in backend_order:
            print('be = %r' % (be,))
            pyperclip.set_clipboard(be)
            %timeit pyperclip.copy('a line of reasonable length text')
            %timeit pyperclip.paste()
    """
    import pyperclip
    import ubelt as ub
    def _check_clipboard_backend(backend):
        if backend == 'qt':
            try:
                import PyQt5  # NOQA
                return True
            except ImportError:
                return False
        elif backend == 'gtk':
            try:
                import gtk  # NOQA
                return True
            except ImportError:
                return False
        else:
            return pyperclip._executable_exists(backend)
    def _ensure_clipboard_backend():
        # TODO: vimtk can do this, use that instead
        if ub.POSIX:
            backend_order = ['xclip', 'xsel', 'qt', 'gtk']
            for backend in backend_order:
                if getattr(pyperclip, '_hacked_clipboard', 'no') == backend:
                    break
                elif _check_clipboard_backend(backend):
                    pyperclip.set_clipboard(backend)
                    pyperclip._hacked_clipboard = backend
                    break
                else:
                    print('warning %r not installed' % (backend,))
    _ensure_clipboard_backend()
    pyperclip.copy(text)
    # from Tkinter import Tk
    # tk_inst = Tk()
    # tk_inst.withdraw()
    # tk_inst.clipboard_clear()
    # tk_inst.clipboard_append(text)
    # tk_inst.destroy()


def open_url_in_browser(url, browsername=None, fallback=False):
    r"""
    Opens a url in the specified or default browser

    Args:
        url (str): web url

    CommandLine:
        xdoctest -m utool.util_grabdata --test-open_url_in_browser

    Example:
        >>> # DISABLE_DOCTEST
        >>> # SCRIPT
        >>> url = 'http://www.jrsoftware.org/isdl.php'
        >>> open_url_in_browser(url, 'chrome')
    """
    import webbrowser
    print('[utool] Opening url=%r in browser' % (url,))
    if browsername is None:
        browser = webbrowser.open(url)
    else:
        browser = get_prefered_browser(pref_list=[browsername], fallback=fallback)
    return browser.open(url)


def get_prefered_browser(pref_list=[], fallback=True):
    r"""
    Args:
        browser_preferences (list): (default = [])
        fallback (bool): uses default if non of preferences work (default = True)

    CommandLine:
        xdoctest -m utool.util_grabdata --test-get_prefered_browser

    Ignore:
        import webbrowser
        webbrowser._tryorder
        pref_list = ['chrome', 'firefox', 'google-chrome']
        pref_list = ['firefox', 'google-chrome']

    Example:
        >>> # DISABLE_DOCTEST
        >>> from utool.util_grabdata import *  # NOQA
        >>> browser_preferences = ['firefox', 'chrome', 'safari']
        >>> fallback = True
        >>> browser = get_prefered_browser(browser_preferences, fallback)
        >>> result = ('browser = %s' % (str(browser),))
        >>> print(result)
        >>> ut.quit_if_noshow()
    """
    import webbrowser
    import ubelt as ub
    pref_list = pref_list if ub.iterable(pref_list) else [pref_list]
    error_list = []

    def listfind(list_, tofind):
        try:
            return list_.index(tofind)
        except ValueError:
            return None

    # Hack for finding chrome on win32
    if ub.WIN32:
        # http://stackoverflow.com/questions/24873302/webbrowser-chrome-exe-does-not-work
        win32_chrome_fpath = 'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe'
        win32_chrome_browsername = win32_chrome_fpath + ' %s'
        win32_map = {
            'chrome': win32_chrome_browsername,
            'google-chrome': win32_chrome_browsername,
        }
        for browsername, win32_browsername in win32_map.items():
            index = listfind(pref_list, browsername)
            if index is not None and True:
                pref_list.insert(index + 1, win32_browsername)

    for browsername in pref_list:
        try:
            browser = webbrowser.get(browsername)
            return browser
        except webbrowser.Error as ex:
            error_list.append(ex)
            print(str(browsername) + ' failed. Reason: ' + str(ex))

    if fallback:
        browser = webbrowser
        return browser
    else:
        raise AssertionError('No browser meets preferences=%r. error_list=%r' %
                             (pref_list, error_list,))


if __name__ == '__main__':
    r"""
    CommandLine:
        python ~/local/vim/rc/pyvim_funcs.py
    """
    import xdoctest
    xdoctest.doctest_module(__file__)
