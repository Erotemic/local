func! CopyGVimToTerminalDev(...) range
    " Interactive scripting function. Takes part of the file you are editing
    " and pastes it into a terminal and then returns the editor to focus.
Python2or3 << EOF
import vim
import ubelt as ub
import vimtk

argv = vimtk.vim_argv(defaults=['clipboard', '1'])
mode = argv[0]
return_to_vim = argv[1] != '0'

DEBUG_STDOUT = False
DEBUG_FILE = False
DEBUG = DEBUG_FILE or DEBUG_STDOUT

def dprint(msg):
    if DEBUG_STDOUT or DEBUG_FILE:
        import time
        stamp = str(time.time())
        msg = stamp + ' ' + msg

    if DEBUG_STDOUT:
        print(msg)

    if DEBUG_FILE:
        file.write(msg + '\n')

def _context_func(file=None):
    dprint('\n----\nCopyGVimToTerminalDev')
    dprint('mode = %r' % (mode,))
    dprint('return_to_vim = %r' % (return_to_vim,))

    if mode == 'clipboard':
        dprint('Text is already in clipboard')
        # Using pyperclip seems to freeze.
        # Access clipboard via vim instead
        text = vim.eval('@+')
        dprint('got text')
        dprint('text = %r' % (text,))
    else:
        if mode == 'word':
            text = vimtk.TextSelector.word_at_cursor()
        else:
            if 'v' in mode.lower():
                dprint('grabbing selected text')
                text = vimtk.TextSelector.selected_text()
            else:
                dprint('grabbing text at current line')
                text = vimtk.TextSelector.line_at_cursor()
        # Prepare to send text to xdotool
        text = ub.codeblock(text)
        #dprint('copying text to clipboard')
        #ut.copy_text_to_clipboard(text)
        #dprint('copied text to clipboard')

    # Preprocess the strings a bit
    dprint('preprocesing the text')
    lines = text.splitlines(True)

    # Handle C++ pybind11 docs
    import re
    if all(re.match('" *(>>>)|(\.\.\.) .*', line) for line in lines):
        if all(line.strip().endswith('"') for line in lines):
            new_lines = []
            for line in lines:
                if line.endswith('\\n"\n'):
                    line = line[1:-4] + '\n'
                elif line.endswith('"\n'):
                    line = line[1:-2] + '\n'
                elif line.endswith('\\n"'):
                    line = line[1:-3]
                elif line.endswith('"'):
                    line = line[1:-1]
                else:
                    raise AssertionError('unknown case')
                new_lines.append(line)
            lines = new_lines
            text = ub.codeblock(''.join(lines))
            text = ub.codeblock(text)
            lines = text.splitlines(True)
            #[line[re.search('(>>>|\.\.\.)', line).end():-1] for line in lines]
            #if all(line.startswith('"') for line in lines):
            #pass

    # Strip docstring prefix
    if all(line.startswith(('>>> ', '...')) for line in lines):
        lines = [line[4:] for line in lines]
        text = ''.join(lines)
    text = ub.codeblock(text)

    vimtk.execute_text_in_terminal(text, return_to_vim=return_to_vim)

if DEBUG_STDOUT:
    from os.path import expanduser
    with open(expanduser('~/vim-misc-debug.txt'), 'a') as file:
        _context_func(file)
else:
    _context_func()
#L______________
EOF
endfu 



" copy whatever is in clipboard to terminal
noremap  <leader>z :call CopyGVimToTerminalDev('clipboard', 1)<CR>
"+========= Not so used 
"noremap  <leader>a :call CopyGVimToTerminalDev(mode(), 1)<CR>
"vnoremap <leader>a :call CopyGVimToTerminalDev(visualmode(), 1)<CR>
"noremap  <leader>w :call CopyGVimToTerminalDev('word', 1)<CR>
"noremap  <leader>m :call CopyGVimToTerminalDev('word', 1)<CR>
noremap  <leader>pd :call CopyGVimToTerminalDev(mode(), 1)<CR>
vnoremap <leader>pd :call CopyGVimToTerminalDev(visualmode(), 1)<CR>
noremap  <leader>pg vip :call CopyGVimToTerminalDev('v', 1)<CR>
" Paste to ipython and STAY in ipython
noremap  <leader>ps :call CopyGVimToTerminalDev(mode(), 0)<CR>
vnoremap <leader>ps :call CopyGVimToTerminalDev(visualmode(), 0)<CR>
" Re-paste selection
noremap  <leader>pr :call CopyGVimToTerminalDev('v', 1)<CR>
" paste single word / var
noremap  <leader>pw :call CopyGVimToTerminalDev('word', 1)<CR>

