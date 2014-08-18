set encoding=utf8

"===========PLUGINS==========="
" PLUGIN: Pathogen
" Pathogen is the first thing to run
"filetype off
let g:pathogen_disabled = []  " Add a plugin to this list to disable it
source ~/local/vim/vimfiles/autoload/pathogen.vim
execute pathogen#infect()
call pathogen#helptags()


"call pathogen#infect()
syntax on
filetype plugin indent on

" PLUGIN: External non-plugin source files
source ~/local/vim/rc/align.vim
source ~/local/vim/rc/custom_pep8_functions.vim

"===========Settings==========="
source ~/local/vim/rc_settings/guivim.vim
source ~/local/vim/rc_settings/behaviors.vim
source ~/local/vim/rc_settings/autocommands.vim
source ~/local/vim/rc_settings/remaps.vim


" Trial / project / temporary vimrc commands
" If they are good put them into a settings file

"___________________
" Quick File Access:
:call QUICKOPEN_leader_tvio(',', '~/local/vim/core_vim.vim')
:call QUICKOPEN_leader_tvio('(', '~/code/utool/cyth/cyth_script')
:call QUICKOPEN_leader_tvio('u', '~/code/utool/utool/__init__.py')
:call QUICKOPEN_leader_tvio('v', '~/code/vtool/vtool/__init__.py')
