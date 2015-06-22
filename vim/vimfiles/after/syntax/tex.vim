" Refererences:  http://stackoverflow.com/questions/23486512/how-can-i-augment-an-existing-set-of-syntax-rules-for-a-filetype-in-vim-withou

" DUPLICATED FROM $VIMRUNTIME/syntax/tex.vim
"let s:tex_fast= "bcmMprsSvV"
"if exists("g:tex_fast")
" if type(g:tex_fast) != 1
"  let s:tex_fast= ""
" else
"  let s:tex_fast= g:tex_fast
" endif
" let s:tex_no_error= 1
"else
" let s:tex_fast= "bcmMprsSvV"
"endif/

let s:extfname=expand("%:e")
if exists("g:tex_stylish")
 let b:tex_stylish= g:tex_stylish
elseif !exists("b:tex_stylish")
 if s:extfname == "sty" || s:extfname == "cls" || s:extfname == "clo" || s:extfname == "dtx" || s:extfname == "ltx"
  let b:tex_stylish= 1
 else
  let b:tex_stylish= 0
 endif
endif


" Adapted FROM $VIMRUNTIME/syntax/tex.vim
"if s:tex_fast =~ 'v'
  if exists("g:tex_verbspell") && g:tex_verbspell
   syn region texZone		start="\\begin{[cC]omment}"		end="\\end{[cC]omment}\|%stopzone\>"	contains=@Spell
   " listings package:
   syn region texZone		start="\\begin{lstlisting}"		end="\\end{lstlisting}\|%stopzone\>"	contains=@Spell
   if version < 600
    syn region texZone		start="\\comment\*\=`"			end="`\|%stopzone\>"			contains=@Spell
    syn region texZone		start="\\comment\*\=#"			end="#\|%stopzone\>"			contains=@Spell
   else
     if b:tex_stylish
      syn region texZone		start="\\comment\*\=\z([^\ta-zA-Z@]\)"	end="\z1\|%stopzone\>"			contains=@Spell
     else
      syn region texZone		start="\\comment\*\=\z([^\ta-zA-Z]\)"	end="\z1\|%stopzone\>"			contains=@Spell
     endif
   endif
  else
   syn region texZone		start="\\begin{[cC]omment}"		end="\\end{[cC]omment}\|%stopzone\>"
   if version < 600
    syn region texZone		start="\\comment\*\=`"			end="`\|%stopzone\>"
    syn region texZone		start="\\comment\*\=#"			end="#\|%stopzone\>"
   else
     if b:tex_stylish
       syn region texZone		start="\\comment\*\=\z([^\ta-zA-Z@]\)"	end="\z1\|%stopzone\>"
     else
       syn region texZone		start="\\comment\*\=\z([^\ta-zA-Z]\)"	end="\z1\|%stopzone\>"
     endif
   endif
  endif
"endif


  syn region texRefZone		matchgroup=texStatement start="\\\(page\|eq\)cref{"	end="}\|%stopzone\>"	contains=@texRefGroup
  syn region texRefZone		matchgroup=texStatement start="\\v\=cref{"		end="}\|%stopzone\>"	contains=@texRefGroup

  syn region texRefZone		matchgroup=texStatement start="\\\(page\|eq\)ucref{"	end="}\|%stopzone\>"	contains=@texRefGroup
  syn region texRefZone		matchgroup=texStatement start="\\v\=ucref{"		end="}\|%stopzone\>"	contains=@texRefGroup

  syn region texRefZone		matchgroup=texStatement start="\\\(page\|eq\)dref{"	end="}\|%stopzone\>"	contains=@texRefGroup
  syn region texRefZone		matchgroup=texStatement start="\\v\=dref{"		end="}\|%stopzone\>"	contains=@texRefGroup

  syn region texRefZone		matchgroup=texStatement start="\\\(page\|eq\)Dref{"	end="}\|%stopzone\>"	contains=@texRefGroup
  syn region texRefZone		matchgroup=texStatement start="\\v\=Dref{"		end="}\|%stopzone\>"	contains=@texRefGroup

  syn region texRefZone		matchgroup=texStatement start="\\\(page\|eq\)Cref{"	end="}\|%stopzone\>"	contains=@texRefGroup
  syn region texRefZone		matchgroup=texStatement start="\\v\=Cref{"		end="}\|%stopzone\>"	contains=@texRefGroup

  syn region texRefZone		matchgroup=texStatement start="\\subimport{common}{"	end="}\|%stopzone\>"	contains=@texRefGroup
  syn region texRefZone		matchgroup=texStatement start="\\v\=subimport{common}{"		end="}\|%stopzone\>"	contains=@texRefGroup

"HiLink texZone		PreCondit
syn match  texRefZone		'\\ucite\%([tp]\*\=\)\=' nextgroup=texRefOption,texCite
