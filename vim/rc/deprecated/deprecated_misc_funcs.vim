

func! GrepWordAtCursor(...) 
Python2or3 << EOF
import vim
import pyvim_funcs
import re

argv = pyvim_funcs.vim_argv(defaults=['project'])
mode = argv[0]

word = pyvim_funcs.get_word_at_cursor(url_ok=False)
print('Grepping for pattern = %r' % (word,))
pat = r'\b' + re.escape(word) + r'\b'

pyvim_funcs.vim_grep(pat, mode=mode, hashid=word)
EOF
endfunc


func! FUNC_GrepProject(...) 
Python2or3 << EOF
import vim
import pyvim_funcs
argv = pyvim_funcs.vim_argv(defaults=[None])
pat = argv[0]
#pat, mode = argv
pyvim_funcs.vim_grep(pat, mode='project')

EOF
endfunc
command! -nargs=1 GrepProject call FUNC_GrepProject(<f-args>)


func! FUNC_Grep(...) 
Python2or3 << EOF
import vim
import pyvim_funcs

argv = pyvim_funcs.vim_argv(defaults=[None])
pat = argv[0]
#pat, mode = argv
pyvim_funcs.vim_grep(pat, mode='normal')

EOF
endfunc
command! -nargs=1 Grep call FUNC_Grep(<f-args>)


func! FUNC_GrepRepo(...) 
Python2or3 << EOF
import vim
import pyvim_funcs

argv = pyvim_funcs.vim_argv(defaults=[None])
pat = argv[0]
#pat, mode = argv
pyvim_funcs.vim_grep(pat, mode='repo')

EOF
endfunc
command! -nargs=1 GrepRepo call FUNC_GrepRepo(<f-args>)


func! SmartSearchWordAtCursor() 
Python2or3 << EOF
import vim
import pyvim_funcs
word = pyvim_funcs.get_word_at_cursor(url_ok=True)

word = pyvim_funcs.extract_url_embeding(word)

print('word = {!r}'.format(word))
if pyvim_funcs.is_url(word):
    url = word
    print(url)
else:
    bibtex_dict = pyvim_funcs.get_bibtex_dict()
    title = bibtex_dict[word]['title'].replace('{', '').replace('}', '')
    pyvim_funcs.copy_text_to_clipboard(title)
    # scholar search
    baseurl = r'https://scholar.google.com/scholar?hl=en&q='
    suffix = '+'.join(title.split(' '))
    url = baseurl + suffix
    print(title)

#import webbrowser
#webbrowser.open(url)
pyvim_funcs.open_url_in_browser(url, 'google-chrome')
EOF
endfunc


"noremap <leader>es :call SmartSearchWordAtCursor()<CR>
noremap <leader>eg :call GrepWordAtCursor('normal')<CR>
noremap <leader>ep :call GrepWordAtCursor('project')<CR>
"noremap <leader>egg :call GrepWordAtCursor('normal')<CR>



func! OpenPathAtCursor(...) 
Python2or3 << EOF
"""
Does a fancy open of a path at the current cursor position in vim
"""
import vim
import pyvim_funcs
import re
from os.path import exists, expanduser

argv = pyvim_funcs.vim_argv(defaults=['split'])
mode = argv[0]


# If the word is a python module try and open it
if pyvim_funcs.is_module_pythonfile():
    #import ubelt as ub
    pass
    #ub.modname_to_modpath()

path = pyvim_funcs.get_word_at_cursor(url_ok=True)
verbose = 1
if verbose:
    print('OpenPathAtCursor path = {!r}'.format(path))
    print('exists = {!r}'.format(exists(path)))
pyvim_funcs.find_and_open_path(path, mode=mode, verbose=verbose)
EOF
endfunc



" Open file under cursor

" In current v/split or new tab
"noremap <leader>go :call OpenPathAtCursor("e")<CR>
"noremap <leader>gf :call OpenPathAtCursor("e")<CR>
"noremap <leader>gi :call OpenPathAtCursor("split")<CR>
"noremap <leader>gv :call OpenPathAtCursor("vsplit")<CR>
"noremap <leader>gv :call OpenPathAtCursor("vsplit")<CR>
"noremap <leader>gt :call OpenPathAtCursor("tabe")<CR>
"noremap gi :call OpenPathAtCursor("split")<CR>

"noremap <leader>gi :wincmd f<CR> 
"noremap gi :wincmd f<CR> 



func! FUNC_OpenPath(...)
Python2or3 << EOF
"""
Does a fancy open of a path specified as an function arg.
"""
import vim
import pyvim_funcs
import re
from os.path import exists, expanduser
argv = pyvim_funcs.vim_argv(defaults=[None, 'split'])
path, mode = argv[0:2]
pyvim_funcs.find_and_open_path(path, mode=mode, verbose=1)
EOF
endfunc

command! -nargs=1 SplitPath call FUNC_OpenPath(<f-args>, 'split')
command! -nargs=1 OpenPath call FUNC_OpenPath(<f-args>, 'e')
command! -nargs=1 EE call FUNC_OpenPath(<f-args>, 'e')


func! SortLinesByFloat() range
'<,'>!sort -n -k 2
"Python2or3 << EOF
"import vim
"import pyvim_funcs; pyvim_funcs.reload(pyvim_funcs)
"text = pyvim_funcs.get_selected_text(select_at_cursor=False)
"##wrapped_text = ut.format_single_paragraph_sentences(text)
"wrapped_text = ut.format_multiple_paragraph_sentences(text)
"pyvim_funcs.insert_codeblock_over_selection(wrapped_text)
"endpython
endfunc



func! MakePrintVar() 
Python2or3 << EOF
# DEPRECATED in favor of vimtk#insert_print_var_at_cursor
import vim
import pyvim_funcs
import ubelt as ub

expr = pyvim_funcs.get_word_at_cursor()
indent = pyvim_funcs.get_cursor_py_indent()

filetype = pyvim_funcs.get_current_filetype()
print('filetype = {!r}'.format(filetype))
if filetype == 'sh':
    statement = 'echo "{expr} = ${expr}"'.format(expr=expr)
elif filetype in {'cmake'}:
    statement = 'message(STATUS "{expr} = ${{{expr}}}")'.format(expr=expr)
elif filetype in {'cpp', 'cxx', 'h'}:
    current_fpath = pyvim_funcs.get_current_fpath()
    if any(n in current_fpath for n in ['vital', 'kwiver', 'sprokit']):
        if pyvim_funcs.find_pattern_above_row(
            '\s*auto logger = kwiver::vital::get_logger.*') is None:
            statement = ub.codeblock(
                '''
                auto logger = kwiver::vital::get_logger("temp.logger");
                LOG_INFO(logger, "{expr} = " << {expr} );
                '''
            ).format(expr=expr)
        else:
            statement = ub.codeblock(
                '''
                LOG_INFO(logger, "{expr} = " << {expr} );
                '''
            ).format(expr=expr)
    else:
        cout = 'std::cout'
        endl = 'std::endl'
        #statement = '{cout} << "{expr} = \\"" << {expr} << "\\"" << {endl};'.format(
        #    expr=expr, cout=cout, endl=endl)
        statement = '{cout} << "{expr} = " << {expr} << {endl};'.format(
            expr=expr, cout=cout, endl=endl)
    # statement = 'printf("{expr} = %s\\n", {expr});'.format(expr=expr)
    pass
else:
    # Default to python
    #newline = indent + "print('{expr} = %r' % ({expr},))".format(expr=expr)
    statement = "print('{expr} = {{!r}}'.format({expr}))".format(expr=expr)

newline = indent + statement.replace('\n', '\n' + indent)
pyvim_funcs.insert_codeblock_under_cursor(newline)
EOF
endfunc


"noremap <leader>pv :call MakePrintVar()<CR>
"noremap <leader>pv :call vimtk_snippets#insert_print_var_at_cursor()<CR>


func! FUNC_IReplace(...)
Python2or3 << EOF
"""
Search and replace while ignoring caps 
"""
import vim
import pyvim_funcs
import re
from os.path import exists, expanduser
argv = pyvim_funcs.vim_argv(defaults=[None, None])
find, repl = argv[0:2]
#print('find = {!r}'.format(find))
#print('repl = {!r}'.format(repl))

n_changed = 0

for lx in range(len(vim.current.buffer)):
    line = vim.current.buffer[lx]
    newline = line
    newline = newline.replace(find, repl)
    newline = newline.replace(find.lower(), repl.lower())
    newline = newline.replace(find.upper(), repl.upper())
    if line != newline:
        vim.current.buffer[lx] = newline
        n_changed += 1
print('found and replaced {!r} matches'.format(n_changed))
EOF
endfunc



func! PySelectAndFormatParagraph(...) 
Python2or3 << EOF
# DEPRECATED IN FAVOR OF vimtk#format_paragraph

import vim
import pyvim_funcs
import utool as ut
import ubelt as ub
nargs = int(vim.eval('a:0'))
# Simulate kwargs with cfgdict-like strings
default_kwargs = {
    'max_width': 80,
    'myprefix': True,
    'sentence_break': True,
}
if nargs == 1:
    cfgstr = vim.eval('a:1')
    cfgdict = ut.parse_cfgstr3(cfgstr)
    kwargs = ut.update_existing(default_kwargs, cfgdict, assert_exists=True)
else:
    kwargs = default_kwargs

# Remember curor location as best as possible
(row, col) = vim.current.window.cursor

row1, row2 = pyvim_funcs.get_paragraph_line_range_at_cursor()
text = pyvim_funcs.get_text_between_lines(row1, row2)
text = ub.ensure_unicode(text)

#wrapped_text = ut.format_multiple_paragraph_sentences(text, max_width=100)
wrapped_text = ut.format_multiple_paragraph_sentences(text, **kwargs)
pyvim_funcs.insert_codeblock_between_lines(wrapped_text, row1, row2)

# Reset cursor position as best as possible
pyvim_funcs.move_cursor(row, col)

EOF
endfunc


func! PySelectAndFormatParagraphNoBreak() 
Python2or3 << EOF
import vim
import pyvim_funcs
import utool as ut
import ubelt as ub
row1, row2 = pyvim_funcs.get_paragraph_line_range_at_cursor()
text = pyvim_funcs.get_text_between_lines(row1, row2)
text = ub.ensure_unicode(text)
wrapped_text = ut.format_multiple_paragraph_sentences(text, max_width=None)
pyvim_funcs.insert_codeblock_between_lines(wrapped_text, row1, row2)
EOF
endfunc



func! PyFormatParagraph() range
Python2or3 << EOF
import vim
import pyvim_funcs
import utool as ut
text = pyvim_funcs.get_selected_text(select_at_cursor=False)
##wrapped_text = ut.format_single_paragraph_sentences(text)
wrapped_text = ut.format_multiple_paragraph_sentences(text)
pyvim_funcs.insert_codeblock_over_selection(wrapped_text)
EOF
endfunc





"vnoremap <leader>fp :call PyFormatParagraph()<CR>
"vnoremap <leader>fe :call PyFormatParagraph()<CR>
"vnoremap ge :call PyFormatParagraph()<CR>
"noremap <leader>ge :call PySelectAndFormatParagraph()<CR>
"noremap <c-g> :call PySelectAndFormatParagraph('max_width=110')<CR>
"noremap <c-f> :call PySelectAndFormatParagraph('max_width=80,myprefix=False,sentence_break=False')<CR>
"noremap <c-M-G> :call PySelectAndFormatParagraphNoBreak()<CR>
"noremap <leader>ge vip:call PyFormatParagraph()<CR>
":noremap <c-g> vip:call PyFormatParagraph()<CR>


" Define Macros
"let @q=',qw'
"let @2=',qw'

"let @1='40j'
"let @2='40k'

" write a self. in normal mode
"let@s='iself.'
"let@e=':Align ='



"""""""""""
" OLD STUFF
" VVVVVVVVVVVV

" This is one special character which means escape
" I got this by typing Ctrl+Q<ESC> 
" 
" 


"nmap <leader>u :call ToggleNumberLineInvert()<CR>


" TODO: http://stackoverflow.com/questions/3638542/any-way-to-delete-in-vim-without-overwriting-your-last-yank
"noremap d "_d
":noremap <leader><F1> :normal i =%r' % (,)<ESC>hh
" Copy
":noremap <F3> "+y
":inoremap <F3> <ESC>"+ya
" Paste
" Map in both normal and interactive mode
" paseting form clibpard is "+p or "*p
":noremap <F2> "+p
":inoremap <F2> <ESC>"+pa

":noremap <leader><F2> "+y
":inoremap <leader><F2> <ESC>"+ya

" OLD
"noremap <leader>. i>>> 
"
":noremap y "+y
"CMDUNMAP y y

" Remap ESCAPE key to?  ":imap ` <Esc>
"noremap <Del> <Esc>
"noremap <Home> <Esc>
":imap <Del> <Esc>
":call PythonInvert()
":call TeckInvert()
"CMDUNSWAP : ;


"useful funcs for leaderkeys
"noremap <F9> <s-v>
"noremap <F10> <s-v>

":noremap <c-M-B> oimport utool<CR>with utool.embed_on_exception_context:<CR><Esc>
":noremap <c-b> oimport utool<CR>utool.embed()<CR><Esc>
"inoremap <c-M-B> import utool<CR>with utool.embed_on_exception_context:<CR>
"inoremap <c-b> import utool<CR>utool.embed()<CR>
"noremap <leader>/ /\c
"inoremap <leader>d :call InsertDocstr()<CR>
"L__________ Not so used 
"noremap  1 :call CopyGVimToTerminalDev(mode(), 1)<CR>
"noremap  2 :call CopyGVimToTerminalDev(mode() 1)<CR>
"-range PassRange <line1>,<line2>call PrintGivenRange()

" alt-u
"inoremap <M-u> ut.
"inoremap <M-i> import
"inoremap <M-y> from import

" Tabs:
" change next/prev tab
"noremap <leader><Tab> gt
"noremap <leader>` gT
"" <alt+num>: change to the num\th tab
"noremap <M-1> 1gt
"noremap <M-2> 2gt
"noremap <M-3> 3gt
"noremap <M-4> 4gt
"noremap <M-5> 5gt
"noremap <M-6> 6gt
"noremap <M-7> 7gt
"noremap <M-8> 8gt
"noremap <M-9> 9gt
"noremap <M-0> 10gt
"" <leader+num>: change to the num\th tab
"noremap <leader>1 1gt
"noremap <leader>2 2gt
"noremap <leader>3 3gt
"noremap <leader>4 4gt
"noremap <leader>5 5gt
"noremap <leader>6 6gt
"noremap <leader>7 7gt
"noremap <leader>8 8gt
"noremap <leader>9 9gt



" K goes to the help for the object under the cursor.
" This is anoying. Kill the behavior
" Or learn how to use it?
" :noremap K k

" Find lone double quotes
":noremap <leader>"/ :/\([^"]\)"\([^"]\)<CR>
"noremap <leader>"/ :/\([^"]\)\@<="\([^"]\)\@=<CR>
"noremap <leader>s' :%s/\([^"]\)"\([^"]\)/\1'\2/gc<CR>
"
" === F1 ===
" Search
"remap F1 to search for word under cursor
"call FKeyFuncMap('<F1>', '*')
" custom command for opening setupfiles
"noremap  <leader><F1> :call OpenSetups()<CR>
