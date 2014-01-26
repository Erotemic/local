#/usr/bin/python

wget https://minted.googlecode.com/files/minted.sty 
export latex_install=/usr/share/texmf-texlive
mv ./minted.sty
mkdir $latex_install/tex/latex/minted/
mv minted.sty $latex_install/tex/latex/minted/minted.sty
