" LaTeX filetype
"	  Language: LaTeX (ft=tex)
"	Maintainer: Srinath Avadhanula
"		 Email: srinath@fastmail.fm

if !exists('s:initLatexSuite')
	let s:initLatexSuite = 1
	exec 'so '.fnameescape(expand('<sfile>:p:h').'/latex-suite/main.vim')

	silent! do LatexSuite User LatexSuiteInitPost
endif

silent! do LatexSuite User LatexSuiteFileType


"
"http://sourceforge.net/p/vim-latex/mailman/vim-latex-devel/thread/CAOAiV5wSXVc1O2-svDu9JsmN92AnrUKQQriin+3heBp7CpwKOg@mail.gmail.com/
