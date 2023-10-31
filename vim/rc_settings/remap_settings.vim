"-------------------------
"""
" SeeAlso:
"     ~/local/vim/rc/custom_misc_functions.vim
"     ~/local/vim/rc/custom_py_functions.vim
"     ~/local/vim/rc/custom_ipy_interact_funcs.vim
"""
" Function Remaps
"map <F1> :call  ToggleWordHighlight()<CR>
"Map Ctrl+W (navkey) to Ctrl+(navkey) (for split windows)


"-------------------------
" CUSOM VIM COMMAND PREFIX
"
" Remap colon to semicolon in normal and visual mode, but not interactive mode
":call vimtk#remap_all_modes(':',';')
":call vimtk#swap_keys : ;
"VimTK_swap_keys : ;
"CMDSWAP : ;
"-------------------------

"---------------------
" CUSOM VIM LEADER KEY
"
" Map leader key to comma (in all contexts)
let mapleader = ","
let maplocalleader = ","
noremap \ ,
"----------------------

" Generally helpful

" Search and replace under cursor
noremap <leader>ss :%s/\<<C-r><C-w>\>/
"Surround word with quotes
noremap <leader>qw ciw'<C-r>"'<Esc>
noremap <leader>qdw ciw"<C-r>""<Esc>
noremap <leader>qc ciw`<C-r>"`<Esc>


" Stage Hunk Mapping: Note this comes by default with the plugin
" noremap <leader>hs :GitGutterStageHunk<CR>

" File navigation
noremap <C-T> :NERDTree<CR>
noremap <leader>. :NERDTree<CR>
noremap <leader>h :NERDTreeToggle<CR>
"noremap <leader>h :Tlist<CR>
noremap <leader>j :Tagbar<CR>


" Text formatting

vnoremap ge :call vimtk#format_paragraph()<CR>
vnoremap fe :call vimtk#format_paragraph()<CR>
vnoremap fp :call vimtk#format_paragraph()<CR>
noremap <leader>ge :call vimtk#format_paragraph()<CR>
noremap <c-g> :call vimtk#format_paragraph('{"max_width": 110}')<CR>
noremap <c-f> :call vimtk#format_paragraph('{"max_width": 80, "myprefix": False, "sentence_break": False}')<CR>

" Quick reference jumping
noremap <leader>el :call PyCiteLookup()<CR>

" Python Debugging Snippets
noremap  <c-b>   :call vimtk_snippets#insert_xdev_embed()<CR><Esc>
inoremap <c-b>   <Esc>:call vimtk_snippets#insert_xdev_embed()<CR>i

noremap  <m-b>   :call vimtk_snippets#insert_xdev_embed_on_exception_context(mode())<CR><Esc>
vnoremap <m-b>   :call vimtk_snippets#insert_xdev_embed_on_exception_context(visualmode())<CR><Esc>
inoremap <m-b> <Esc>:call vimtk_snippets#insert_xdev_embed_on_exception_context()<CR>i

" Timing
noremap  <c-M-B> :call vimtk_snippets#insert_timerit(mode())<CR><Esc>
vnoremap <c-M-B> :call vimtk_snippets#insert_timerit(visualmode())<CR><Esc>

" Python Autogen Snippets
noremap <leader>d  :call InsertDocstr()<CR>
noremap <leader>ed :call InsertDocstr()<CR>
noremap <leader>ea :call InsertDocstrOnlyArgs()<CR>
noremap <leader>ec :call vimtk_snippets#insert_docstr_commandline()<CR>

noremap <leader>em :call vimtk_snippets#insert_python_main()<CR>
noremap <leader>es :call vimtk_snippets#insert_python_scriptconfig_template()<CR>
noremap <leader>eh :call vimtk_snippets#insert_python_header()<CR>
noremap <leader>eH :call vimtk_snippets#insert_python_header('script')<CR>
noremap <leader>ek :call vimtk_snippets#insert_xdev_global_kwargs()<CR>


noremap <c-d> :call InsertDocstr()<CR>
noremap <c-1> :call InsertDocstr()<CR>
inoremap <c-1> :call InsertDocstr()<CR>

" Misc python snippets

noremap <leader>pl :call MakePrintLine()<CR>
" insert a NOQA
noremap <leader>n A  # NOQA<Esc>
" Change dictionary body to ordered dictionary
noremap <leader>ro :s/^\( *\)\([^ ]\)/\1(\2/ <bar> '<,'>s/,$/),/ <bar> '<,'>s/:/,/<CR>
" Change a dictionary body to a variable assignment
noremap <leader>ra :s/^\( *\)'\([^']*\)'\([^ ]\)/\1\2\3/ <bar> '<,'>s/,$// <bar> '<,'>s/:/ =/<CR>


func! ConvertSelectionToLiteralDict()
Python2or3 << EOF
# Change to a dictionary literal
import vimtk
print(f'vimtk.__file__={vimtk.__file__}')
print(dir(vimtk.Python))
vimtk.reload()
vimtk.Python._convert_selection_to_literal_dict()
EOF
endfunc
noremap <leader>rd :call ConvertSelectionToLiteralDict()<Esc>



func! ConvertSelectionToLiteralDict()
Python2or3 << EOF
# Change to a dictionary literal
import vimtk
print(f'vimtk.__file__={vimtk.__file__}')
print(dir(vimtk.Python))
vimtk.reload()
vimtk.Python._convert_selection_to_literal_dict()
EOF
endfunc


" -------- Interactive Editing
" DO line in ipython and RETURN to vim

"let g:vimtk_default_mappings=1
noremap <leader>H :call vimtk#helloworld()<Esc>

noremap  <leader>a :call vimtk#execute_text_in_terminal(mode())<CR>
vnoremap <leader>a :call vimtk#execute_text_in_terminal(visualmode())<CR>
noremap  <leader>m :call vimtk#execute_text_in_terminal('word')<CR>

"vimtk#execute_text_in_terminal(visualmode())<CR>

noremap <leader>C :call vimtk#copy_current_fpath()<Esc>
noremap <leader>f :call vimtk#copy_current_module()<Esc>

noremap <leader>M :call vimtk#ipython_import_all()<CR>

command! AutoImport call vimtk#insert_auto_import()

noremap <leader>pv :call vimtk#insert_print_var_at_cursor("repr")<CR>
noremap <leader>ps :call vimtk#insert_print_var_at_cursor("urepr")<CR>

noremap  <c-M-B> :call vimtk#insert_timerit(mode())<CR><Esc>
vnoremap <c-M-B> :call vimtk#insert_timerit(visualmode())<CR><Esc>

noremap <leader>gs :call vimtk#smart_search_word_at_cursor()<CR>
noremap <leader>go :call vimtk#open_path_at_cursor("e")<CR>
noremap <leader>gf :call vimtk#open_path_at_cursor("e")<CR>
noremap <leader>gi :call vimtk#open_path_at_cursor("split")<CR>
noremap <leader>gv :call vimtk#open_path_at_cursor("vsplit")<CR>
noremap <leader>gv :call vimtk#open_path_at_cursor("vsplit")<CR>
noremap <leader>gt :call vimtk#open_path_at_cursor("tabe")<CR>
noremap gi :call vimtk#open_path_at_cursor("split")<CR>

" Doctest editing
vnoremap gd :call vimtk#py_format_doctest()<CR>
vnoremap gu :call vimtk#py_unformat_doctest()<CR>

noremap  <leader>x :call IPyFixEmbedGlobals()<CR>

" Focus on terminal
noremap  <leader>ft :call FocusTerm()<CR>
"noremap  <leader>pt :call FocusTerm()<CR>

" Hotkey:
" Refreshing the vim RC / syntax



"func! VimtkReload()
"let __doc__ =<< trim __DOC__
"FIXME: broken, is there any way to do this?

"A workaround is to define this function in your vimrc

"Reloads vimtk after changes are made or it is updated
"__DOC__

"" Unset the guard flags
"let g:loaded_vimtk_autoload = 0
"let g:loaded_vimtk = 0

"" TODO: may have to reload the python module

"" NOTE: this does not work!
"" Resource this file.
"" https://vi.stackexchange.com/questions/26479/refreshing-vim-file-from-within-a-function
":source $MYVIMRC
":exec "source " . g:vimtk_autoload_fpath
"endfunc


noremap <leader>r :source ~/local/vim/portable_vimrc<CR>
noremap <leader>R :source ~/local/vim/portable_vimrc<CR>


" Hack to reload vimtk plugin as well
"let g:loaded_vimtk=0
"let g:loaded_vimtk_autoload=0
"source ~/local/vim/vimfiles/bundle/vimtk/plugin/vimtk.vim
"source ~/local/vim/vimfiles/bundle/vimtk/autoload/vimtk.vim


"noremap <leader>rs :syntax sync minlines=2000<CR>
noremap <leader>rs :syntax sync fromstart<CR>

" for python doctests
inoremap ,,, >>> 
noremap <leader>> :s/^\( *[^ ].*\)\([^ ]\)>>>/\1\2/g<CR>
":noremap <leader>> :'<,'>s/^\( *[^ ].*\)\([^ ]\)>>>/\1\2/g<CR>


" Search in non-doctests
"noremap <leader>/ :/\(^.*>>> .*\)\@<!

" Search in non-doctests and non-comments (DOES NOT WORK BECAUSE not or, cannot
" have a not and I dont think)
let __doc__ =<< trim END
    from xdev.regex_builder import RegexBuilder 
    b = RegexBuilder.coerce('vim')
    not_doctest = b.lookbehind('^.*>>> .*', positive=False)
    not_comment = b.lookbehind('^.*#.*', positive=False)
    print(not_doctest + not_comment)
END

noremap <leader>/ :/\(^.*>>> .*\)\@<!\(^.*#.*\)\@<!

" Function Keys

" === F2 ===
call FKeyFuncMap('<F2>', ':source ~/local/vim/portable_vimrc<CR>')
"call FKeyFuncMap('<F2>', ':call PythonRevert()<CR>')
"call FKeyFuncMap('<F3>', ':call PythonInvert()<CR>')

" === F3 ===
call FKeyFuncMap('<c-F2>', ':call NumberLineRevert()<CR>')
call FKeyFuncMap('<c-F3>', ':call NumberLineInvert()<CR>')
" === F4 ===
"http://vim.1045645.n5.nabble.com/How-to-map-two-commands-on-one-key-td1162164.html
noremap <F4> :call ToggleFont(1) <Bar> redraw <Bar> call FUNC_ECHOVAR("gfn")<CR>
noremap <S-F4> :call ToggleFont(-1) <Bar> redraw <Bar> call FUNC_ECHOVAR("gfn")<CR>
":noremap <C-F4> <Esc>:tabclose<CR>

" === F5, 6, 7
noremap <F5> :call ViewDirectory()<CR>
noremap <F6> :call CmdHere()<CR>

"vim-latex-suit overwrites f5, give it an alt
noremap <F8> :call Tex_RunViewLaTeX()<CR>
noremap <F12> :call ToggleAlpha()<CR>


" Remap Alt+q to escape
inoremap <silent><A-q> <ESC>
" Remap Alt+p to paste
inoremap <silent><A-p> <C-p>

" Window navication
" Alt + jklh
map <silent><A-j> <c-w>j
map <silent><A-k> <c-w>k
map <silent><A-l> <c-w>l
map <silent><A-h> <c-w>h
" Control + jklh
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
" Move in split windows
" Press leader twice to move between windows
noremap <leader>, <C-w>w
map <c-h> <c-w>h


nnoremap <leader>p :call Tex_RunViewLaTeX()<CR>
nmap <C-P> :call Tex_RunViewLaTeX() <CR>
imap <C-P> :call Tex_RunViewLaTeX() <CR>

" Folds:
" Map space to toggle current fold
noremap <space> za
"noremap <leader>z zR
"noremap <leader>a zA
"noremap <leader>m zM


" goto next syntastic error
"noremap <leader>e :SyntasticCheck<CR> :Errors<CR>
noremap <leader>e :ALEPopulateLocList<CR>

" RESIZE VSPLIT
noremap <leader>+ :30winc ><CR>
noremap <leader>_ :30winc <<CR>
noremap <leader>= :FontIncrease<CR>
noremap <leader>- :FontDecrease<CR>


"noremap <leader>H :call vimtk#helloworld()<Esc>


" UNSURE OF THESE 
" VVVVV




" Macro for surround word with quotes
let @q=',qw'
let @r='VG;<c-p>'

" Close a tab
noremap <leader>qt :tabclose<CR>
map <c-`> <c-o>

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" Remap execute macro from @ to \
nmap <leader>2 @

" https://stackoverflow.com/questions/4256697/vim-search-and-highlight-but-do-not-jump
nnoremap <silent> # :let @/= '\<' . expand('<cword>') . '\>' <bar> set hls <cr>
