"-------------------------
" PLUGIN: NERDTree 

func! NERD_TREE_WITH_BAT()
python << endpython
import vim
def nerdtree_withbat():
    # Define ignored suffixes
    ignore_pysuffix  = [
    '.pyo', 
    '.pyc',
    '.shelf'
    ]
    ignore_texsuffix = [
    '.aux', 
    '.masv', 
    '.bbl', 
    '.bst', 
    '.bcf', 
    '.blg', 
    '.brf',
    '.synctex',
    '.upa',
    '.upb',
    '.pdf', 
    #'.out',
    '.log',
    '.latexmain',
    '.glo',
    '.toc', 
    '.xdy',
    '.lof',
    '.lot',
    #'.bib',
    ]
    ignore_imgsuffix = ['.png']
    ignore_suffixes = ignore_pysuffix + ignore_texsuffix + ignore_imgsuffix

    # Define ignored files
    ignore_files = [
    #'README.md', 
    'LICENCE',
    "\'", 
    #"~", 
    ]
    # FIXME: Fix the tilde

    # Convert files and suffixes to regexes
    ignore_suffix_regexes = [suffix.replace('.', '\\.') + '$' for suffix in ignore_suffixes]
    ignore_file_regexes   = ['^' + fname + '$' for fname in ignore_files]
    ignore_regexes = ignore_suffix_regexes + ignore_file_regexes

    # build nerdtreeignore command
    nerdtree_ignore = '[%s]' % (','.join(['"%s"' % str(regex) for regex in ignore_regexes]))
    nerdtree_ignore_cmd = 'let g:NERDTreeIgnore = %s' % nerdtree_ignore
    #print(nerdtree_ignore_cmd)
    vim.command(nerdtree_ignore_cmd)
nerdtree_withbat()
endpython
"let NERDTreeIgnore = ['\.o$', '\~$', '\.pyc$',  '\.pyo$', '\.aux$', '\.masv$', '\.bbl$', '\.bcf$', '\.blg$', '\.brf$', '\.synctex$', '\.upa$', '\.upb$', '\.pdf$', '\.out$', '\.log', '\.latexmain', '\.bib', '\.shelf', 'README.md', 'LICENSE']
endfu

call NERD_TREE_WITH_BAT()

"
"
"-------------------------
" PLUGIN: Syntastic C++
"let g:syntastic_gpp_include_dirs=['$INSTALL_32/OpenCV/include']
"let g:syntastic_cpp_include_dirs=['C:/Program Files (x86)/OpenCV/include']
let g:syntastic_cpp_check_header = 0
let g:syntastic_cpp_no_include_search = 1
let g:syntastic_cpp_no_default_include_dirs =1
let g:syntastic_cpp_remove_include_errors = 1
"let g:syntastic_cpp_include_dirs = ['include', '../include']
"let g:syntastic_cpp_compiler = 'clang++'
"let g:syntastic_c_include_dirs = ['include', '../include']
"let g:syntastic_c_compiler = 'clang'

"-------------------------
" PLUGIN: Tagbar
" https://github.com/majutsushi/tagbar/blob/master/doc/tagbar.txt
"let g:tagbar_indent = 1
let g:tagbar_sort=0
let g:tagbar_compact = 1
"let g:tagbar_compact = 0
let g:tagbar_hide_nonpublic=0
let g:tagbar_autoshowtag = 1
"let g:tagbar_left = 1
let g:tagbar_left = 0

" http://stackoverflow.com/questions/26145505/using-vims-tagbar-plugin-for-latex-files
let g:tagbar_type_tex = {
    \ 'ctagstype' : 'tex2',
\ }


"let g:tagbar_type_tex = {
"    \ 'ctagstype' : 'tex2',
"    \ 'kinds' : [
"        \ 'c:chapters',
"        \ 's:sections',
"        \ 'u:subsections',
"        \ 'b:subsubsections',
"        \ 'P:paragraphs',
"        \ 'l:labels:0:0',
"    \ ],
"    \ 'sort'    : 0,
"\ }

"\ 'i:includes:1:0',
"\ 'p:parts',
"\ 'G:subparagraphs:0:0',

"-------------------------
" PLUGIN: Taglist
" https://justin.abrah.ms/vim/vim_and_python.html
let Tlist_GainFocus_On_ToggleOpen = 1
let Tlist_Close_On_Select = 0
let Tlist_Use_Right_Window = 0
let Tlist_File_Fold_Auto_Close = 1
"let Tlist_Sort_Type = "name"
let Tlist_Sort_Type="order"
let Tlist_Show_One_File=1
let Tlist_Auto_Update=1
let Tlist_Auto_Highlight_Tag = 1
"let Tlist_tex_settings = 'latex;s:sections;t:subsections;u:subsubsections'

" Only for latex
"set iskeyword=@,48-57,_,-,:,192-255


"-------------------------
" PLUGIN: Unimpaired
"https://github.com/tpope/vim-unimpaired


"-------------------------
" PLUGIN: Buffergator
" https://github.com/jeetsukumaran/vim-buffergator/blob/master/doc/buffergator.txt
" Remove mappings that I dont like 
silent! unmap!  <leader><S-Down>  
silent! unmap!  <leader><S-Right>  
silent! unmap!  <leader><S-Up>     
silent! unmap!  <leader><S-Left>   
silent! unmap!  <leader><Down>     
silent! unmap!  <leader><Right>    
silent! unmap!  <leader><Up>       
silent! unmap!  <leader><Left>     
silent! unmap!  <leader>T          
silent! unmap!  <leader>tc         
silent! unmap!  <leader>to         
silent! unmap!  <leader>t          
" 

" VimTweak
let g:vimtweak_focus_transparency=0
let s:ft=0


"-------------------------
"# Jedi?
" Prevent insertion of netrwLeftMouse when clicking on GUI vim (bug introduced
" https://github.com/jrid/vim-jrid/blob/master/vimrc-netrw
" with later netrw plugin)
let g:netrw_mousemaps=0

let g:netrw_altv          = 1
let g:netrw_fastbrowse    = 2
let g:netrw_keepdir       = 0
let g:netrw_liststyle     = 0
let g:netrw_retmap        = 1
let g:netrw_silent        = 1
let g:netrw_special_syntax= 1
