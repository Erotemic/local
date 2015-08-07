"""
Called by ~/local/vim/rc/custom_misc_functions.vim
"""
from os.path import expanduser


def regex_reconstruct_split(pattern, text):
    import re
    #separators = re.findall(pattern, text)
    separators = [match.group() for match in re.finditer(pattern, text)]
    remaining = text
    block_list = []
    for sep in separators:
        head, tail = remaining.split(sep, 1)
        block_list.append(head)
        remaining = tail
    block_list.append(remaining)
    return block_list, separators


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
    import utool as ut
    import re
    min_indent = ut.get_minimum_indentation(text)
    indent_ =  ' ' * min_indent
    formated_text = re.sub('^' + indent_, '' + indent_ + '>>> ', text, flags=re.MULTILINE)
    formated_text = re.sub('^$', '' + indent_ + '>>> #', formated_text, flags=re.MULTILINE)
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
    import utool as ut
    import re
    min_indent = ut.get_minimum_indentation(formated_text)
    indent_ =  ' ' * min_indent
    unformated_text = re.sub('^' + indent_ + '>>> ', '' + indent_, formated_text, flags=re.MULTILINE)
    return unformated_text


def format_multiple_paragraph_sentences(text):
    """

    CommandLine:
        python ~/local/vim/rc/pyvim_funcs.py --test-format_multiple_paragraph_sentences

    Example:
        >>> # DISABLE_DOCTEST
        >>> import os, sys
        >>> sys.path.append(os.path.expanduser('~/local/vim/rc'))
        >>> from pyvim_funcs import *  # NOQA
        >>> text = testdata_text()
        >>> formated_text = format_multiple_paragraph_sentences(text)
        >>> print('--------')
        >>> print(text)
        >>> print('--------')
        >>> print(formated_text)
    """
    import utool as ut
    # Patterns that define separations between paragraphs in latex
    pattern_list = [
        '\n\n\n*',     # newlines
        '\n? *%.*\n',  # comments

        # paragraph commands
        '\n? *\\\\paragraph{[^}]*}\n',
        '\n? *\\\\section{[^}]*}\n',
        '\n? *\\\\subsection{[^}]*}\n',
        '\n? *\\\\newcommand{[^}]*}.*\n',
        # generic multiline commands with text inside (like devcomment)
        '\n? *\\\\[a-zA-Z]+{ *\n',

        '\n? *\\\\begin{[^}]*}\n',
        '\n? *\\\\item *\n',
        '\n? *\\\\noindent *\n',
        '\n? *\\\\end{[^}]*}\n?',
    ]
    pattern = '|'.join(['(%s)' % (pat,) for pat in pattern_list])
    # break into paragraph blocks
    block_list, separators = regex_reconstruct_split(pattern, text)
    #print(pattern)
    #print(separators)
    # apply formatting
    formated_block_list = [format_single_paragraph_sentences(block) for block in block_list]
    rejoined_list = list(ut.interleave((formated_block_list, separators)))
    formated_text = ''.join(rejoined_list)
    return formated_text


def format_single_paragraph_sentences(text, debug=False):
    r"""
    helps me separatate sentences grouped in paragraphs that I have a difficult
    time reading due to dyslexia

    Args:
        text (str):

    Returns:
        str: wrapped_text

    CommandLine:
        python  ~/local/vim/rc/pyvim_funcs.py --test-format_single_paragraph_sentences --exec-mode

    Example:
        >>> # DISABLE_DOCTEST
        >>> from pyvim_funcs import *  # NOQA
        >>> text = '     lorium ipsum? dolar erat. sau.ltum. fds.fd... . . fd oob fd. list: (1) abcd, (2) foobar (3) spam.'
        >>> #text = '? ? . lorium. ipsum? dolar erat. saultum. fds.fd...  fd oob fd. ? '  # causes breakdown
        >>> print('text = %r' % (text,))
        >>> wrapped_text = format_single_paragraph_sentences(text, True)
        >>> result = ('wrapped_text =\n%s' % (str(wrapped_text),))
        >>> print(result)

    """
    import utool as ut
    import textwrap
    import re
    #ut.rrrr(verbose=False)
    min_indent = ut.get_minimum_indentation(text)
    min_indent = (min_indent // 4) * 4
    text_ = ut.remove_doublspaces(text)
    # TODO: more intelligent sentence parsing
    text_ = ut.flatten_textlines(text)
    USE_REGEX_SPLIT = True
    if USE_REGEX_SPLIT:
        # ******* #
        # SPLITS line endings based on regular expressions.
        raw_sep_chars = ['.', '?', '!', ':']
        regex_sep_chars = list(map(re.escape, raw_sep_chars))
        esc = re.escape
        regex_sep_prefix = [esc('(') + r'\d' + esc(')')]
        #regex_sep_prefix = [esc('(') + '[0-9]' + esc(')')]
        regex_sep_list = regex_sep_chars + regex_sep_prefix
        sep_pattern = ut.regex_or(regex_sep_list)
        full_pattern = '(' + sep_pattern + r'+\s)'
        #full_pattern = r'((' + sep_pattern + r'+\s)+)'
        full_regex = re.compile(full_pattern)
        num_groups = full_regex.groups  # num groups in the regex
        #full_pattern = r'((\.+))'
        #full_pattern = r'((\.)+ )'
        #split_list = re.split(full_pattern, text_, flags=re.DOTALL | re.MULTILINE)
        split_list = re.split(full_pattern, text_)
        if len(split_list) > 0:
            #assert len(split_list) % 3 ==  0, 'split has 2 groups and other stuff'
            #if not re.match(full_pattern, split_list[0]):
            #    if len(split_list) > 1:
            #        assert re.match(full_pattern, split_list[1])
            num_bins = num_groups + 1
            sentence_list = split_list[0::num_bins]
            #fullsep_list = split_list[1::3]
            sep_list_group1 = split_list[1::num_bins]
            #sep_list_group2 = split_list[2::num_bins]
            #sep_list_group3 = split_list[num_groups::num_bins]
            sep_list = sep_list_group1
            #sep_list = sep_list_group2
        if debug:
            print('num_groups = %r' % (num_groups,))
            print('len(split_list) = %r' % (len(split_list)))
            print('len(split_list) / len(sentence_list) = %r' % (len(split_list) / len(sentence_list)))
            print('len(sentence_list) = %r' % (len(sentence_list),))
            print('len(sep_list_group1) = %r' % (len(sep_list_group1),))
            #print('len(sep_list_group2) = %r' % (len(sep_list_group2),))
            print('full_pattern = %s' % (full_pattern,))
            #print('split_list = %r' % (split_list,))
            print('sentence_list = %s' % (ut.list_str(sentence_list),))
            print('sep_list = %s' % ((sep_list),))
        # ******* #
    else:
        # Old way that just handled periods
        sentence_list = text_.split('. ')
    # prefix for continuations of a sentence
    sentence_prefix = '  '
    width = 80 - min_indent
    wrapkw = dict(width=width, break_on_hyphens=False, break_long_words=False)
    if text_.startswith('>>>'):
        # Hack to do docstrings
        # TODO: make actualy docstring reformater
        sentence_prefix = '...     '
    #wrapped_lines_list = [textwrap.wrap(sentence_prefix + line, **wrapkw)
    #                      for line in sentence_list]
    wrapped_lines_list = []
    INDENT_FIRST = False
    for count, line in enumerate(sentence_list):
        if INDENT_FIRST:
            wrapped_lines = textwrap.wrap(sentence_prefix + line, **wrapkw)
        else:
            # ******* #
            wrapped_lines = textwrap.wrap(line, **wrapkw)
            wrapped_lines = [line_ if count == 0 else sentence_prefix + line_
                             for count, line_ in enumerate(wrapped_lines)]
            # ******* #
        wrapped_lines_list.append(wrapped_lines)

    wrapped_sentences = ['\n'.join(line) for line in wrapped_lines_list]

    BIG_SEP = False
    if BIG_SEP:
        sepfmt = '%+------\n{}\n%L______'
        wrapped_block =  sepfmt.format('.\n%\n'.join(wrapped_sentences))
    else:
        if USE_REGEX_SPLIT:
            # ******* #
            # put the newline before or after the sep depending on if it is
            # supposed to prefix or suffix the sentence.
            from six.moves import zip_longest
            newsep_list = [sep.strip() + '\n' if sep.strip()[0] in raw_sep_chars else '\n' + sep for sep in sep_list]
            wrapped_sentences2 = []
            for sentence, sep in zip_longest(wrapped_sentences, newsep_list):
                # account for suffix-to-prefix double seperators
                # helps fix things like enumerated stuff: (1) foo (2) you
                if sep is None:
                    sep = ''
                if (sentence == '' and
                        sep.startswith('\n') and
                        len(wrapped_sentences2) > 1 and
                        wrapped_sentences2[-1].endswith('\n')):
                    sep = sep[1:]
                if debug:
                    print('---')
                    print('sentence = %r' % (sentence,))
                    print('sep = %r' % (sep,))
                wrapped_sentences2.append(sentence + sep)
            #wrapped_block = '.\n'.join(wrapped_sentences)
            #wrapped_sentences1 = list(ut.iflatten(zip_longest(wrapped_sentences, newsep_list)))
            #wrapped_sentences2 = ['' if x is None else x for x in wrapped_sentences1]
            if debug:
                print('---')
                print('newsep_list = %r' % (newsep_list,))
                print('len(newsep_list) = %r' % (len(newsep_list),))
                print('len(wrapped_sentences) = %r' % (len(wrapped_sentences),))
            # The wrapped block has a level 0 indentation
            wrapped_block = ''.join(wrapped_sentences2)
            # ******* #
        else:
            wrapped_block = '.\n'.join(wrapped_sentences)

    # Do the final indentation
    wrapped_text = ut.indent(wrapped_block, ' ' * min_indent)
    return wrapped_text


def testdata_text():
    text = r'''
        % COMMENT
        Image matching relies on finding similar features between query and
        database images, and there are many factors that can cause this to be
        difficult.
        % TALK ABOUT APPEARANCE HERE
        Similar to issues seen in (1) instance and (2) face recognition,
        images of animals taken ``in the wild'' contain many challenges such as
        occlusion, distractors and variations in viewpoint, pose, illumination,
        quality, and camera parameters.  We start the discussion of the problem
        addressed in this thesis by considering examples of these challenges.

        \distractorexample

        \paragraph{foobar}
        Occluders are objects in the foreground of an image that impact the
        visibility of the features on the subject animal.
         Both scenery and other animals are the main contributors of occlusion in
        our dataset.
         Occlusion from other animals is especially challenging because not only

        \begin{enumerate} % Affine Adaptation Procedure
           \item Compute the second moment matrix at the warped image patch defined by $\ellmat_i$.

           \item If the keypoint is stable, stop.  If convergence has not been reached in
                some number of iterations stop and discard the keypoint.

           \item
                  Update the affine shape  using the rule $\ellmat_{i + 1} =
                \sqrtm{\momentmat} \ellmat_i$.
                  This ensures the eigenvalues at the previously detected point
                are equal in the new frame.
                  If the keypoint is stable, it should be re-detected close to
                the same location.
                  (The square root of a matrix defined as:
                $\sqrtm{\momentmatNOARG} \equiv \mat{X} \where \mat{X}^T\mat{X}
                = \momentmatNOARG$.
                  If $\momentmatNOARG$ is degenerate than $\mat{X}$ does not
                exist.)
        \end{enumerate}
    '''.strip('\n')
    return text


def get_line_at_cursor():
    import vim
    buf = vim.current.buffer
    (row, col) = vim.current.window.cursor
    line = buf[row - 1]  # Original end of the file
    return line


def get_word_at_cursor():
    """ returns the word highlighted by the curor """
    import vim
    buf = vim.current.buffer
    (row, col) = vim.current.window.cursor
    line = buf[row - 1]  # Original end of the file
    nonword_chars = ' \t\n\r[](){}:;.,"\'\\/'
    word = get_word_in_line_at_col(line, col, nonword_chars)
    return word


def get_expr_at_cursor():
    """ returns the word highlighted by the curor """
    import vim
    buf = vim.current.buffer
    (row, col) = vim.current.window.cursor
    line = buf[row - 1]  # Original end of the file
    nonword_chars = ' \t\n\r[](){}:;,"\'\\/='
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


def get_selected_text():
    """ make sure the vim function calling this has a range after () """
    import vim
    buf = vim.current.buffer
    (lnum1, col1) = buf.mark('<')
    (lnum2, col2) = buf.mark('>')
    lines = vim.eval('getline({}, {})'.format(lnum1, lnum2))
    if len(lines) == 1:
        lines[0] = lines[0][col1:col2 + 1]
    else:
        lines[0] = lines[0][col1:]
        lines[-1] = lines[-1][:col2 + 1]
    return "\n".join(lines)


def insert_codeblock_over_selection(text):
    import vim
    buf = vim.current.buffer
    # These are probably 1 based
    (row1, col1) = buf.mark('<')
    (row2, col2) = buf.mark('>')
    buffer_tail = vim.current.buffer[row2:]  # Original end of the file
    lines = [line.encode('utf-8') for line in text.split('\n')]
    new_tail  = lines + buffer_tail
    del(vim.current.buffer[row1 - 1:])  # delete old data
    vim.current.buffer.append(new_tail)  # append new data


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


def find_pyfunc_above_cursor():
    import vim
    import utool as ut
    # Get text posision
    (row, col) = vim.current.window.cursor
    line_list = vim.current.buffer
    return ut.find_pyfunc_above_row(line_list, row)


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
    """
    from os.path import dirname
    import utool as ut
    ut.rrrr(verbose=False)
    import vim
    modname = ut.get_modname_from_modpath(vim.current.buffer.name)
    moddir = dirname(vim.current.buffer.name)
    return modname, moddir


def auto_docstr(**kwargs):
    import imp
    import utool as ut
    imp.reload(ut)
    ut.rrrr(verbose=False)
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
            modname = modname
            # Text to insert into the current buffer
            autodockw = {'verbose': True}
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
    ut.doctest_funcs()
