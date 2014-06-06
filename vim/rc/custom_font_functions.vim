func! ToggleFont() 
    if !exists("g:togfont") 
        let g:togfont=1
    endif
    python << endpython
import vim
togfont = int(vim.eval('g:togfont'))
togfont += 1
vim.command('let g:togfont=%r' % togfont)
endpython
    
    "else 
    "    let g:togfont = 1 - g:togfont 
    "endif 
    "else
        "let g:togfont = 1 + g:togfont
    "endif
    "if (g:togfont)
    "    :call SetFontDyslexic()
    "else 
    "    :call SetFontClean()
    "endif 
    
    call SetFuzzyFont(g:togfont)
endfu 


fu! SetMyFont()
    call SetFuzzyFont("monodyslexic")
    "call SetFontDyslexic()
    "call SetFontClean()
endfu


" Setting Font Functions
fu! SetFontClean()
    if has("win32") || has("win16")
        call SetFuzzyFont("monofur")
        "call SetFuzzyFont("lucida console")
        "call SetFuzzyFont("Inconsolata")
    else
        "set gfn=Ubuntu\ Mono\ 9
        "set gfn=Neep\ Alt\ Medium\ Semi-Condensed\ 11
        set gfn=Neep\ 11
    endif
endfu


fu! SetFuzzyFont(fontid)
    let fontid=a:fontid
python << endpython
import vim
import sys
import Levenshtein  # Edit distance algorithm
from operator import itemgetter
request = vim.eval('fontid')
win32_fonts = [
    r'Mono\ Dyslexic:h10',
    #r'Inconsolata:h10',
    r'Inconsolata:h11',
    #r'Source_Code_Pro:h11:cANSI',
    #r'peep:h11:cOEM',
    r'monofur:h11',
    #r'Consolas',
    #r'Liberation Mono',
    #r'Lucida_Console:h10',
    #r'Fixedsys',
    #r'Courier:h10:cANSI',
    #r'Courier New',
    #r'DejaVu Sans Mono',
]
linux_fonts = [
    r'MonoDyslexic\ 9.4',
    r'Neep\ 11',
    r'monofur\ 11',
    r'White\ Rabbit\ 11',
    r'Courier\ New\ 11',
    r'Nimbus\ Mono\ L\ 11', 
]
if sys.platform.startswith('win32'):
    known_fonts = win32_fonts
else:
    known_fonts = linux_fonts

def vimprint(message):
    vim.command(':silent !echom %r' % message)
    #vim.command(':echom %r' % message)

vimprint('request=%r %r' % (type(request), request))

int_str = map(str, range(0, 9))
is_integer_str = all([_ in int_str for _ in request])
    
if isinstance(request, (str)) and not is_integer_str:
    # Calcualate edit distance to each known font
    known_dists = [Levenshtein.distance(known.lower(), request.lower()) for known in known_fonts]

    # Pick the minimum distance
    min_index = min(enumerate(known_dists), key=itemgetter(1))[0]
    fontindex = min_index
else:
    fontindex = int(request) % len(known_fonts)

fontstr = known_fonts[fontindex]
# Set as current font
vimprint('index=%r fontstr=%r' % (fontindex, fontstr))
vimprint('numfonts=%r' % (len(known_fonts)))
vim.command('set gfn=' + fontstr)
endpython
:ECHOVAR gfn
endfu



" Multiple arguments
func! QUICKOPEN_leader_tvio(...)
    let key = a:1
    let fname = a:2
endfu
" 


" Setting Font Functions
fu! SetFontDyslexic()
    if has("win32") || has("win16")
        "set gfn=Mono\ Dyslexic:h11
        set gfn=Mono\ Dyslexic:h10
    else
        set gfn=MonoDyslexic\ 9.4
    endif
endfu

fu! SetFontDefault()
    if has("win32") || has("win16")
        set gfn=Fixedsys:h9
    else
        set gfn=Monospace
    endif
endfu

function! FontDecrease()
    call AdjustFontSize(-1)
endfunction
command! FontDecrease call FontDecrease()


function! FontIncrease()
    call AdjustFontSize(1)
endfunction
command! FontIncrease call FontIncrease()

" NEW QUICK INCREASE FONT STUFF
function! AdjustFontSize(amount)
    "                     part1       part2      part3
    let font_pattern = '^\(.*\):h\([0-9][0-9]*\)\(.*$\)'
    let min_sz = 6
    let max_sz = 16
    if has("gui_running")
        let oldfont = substitute(&gfn, font_pattern, '\1', '')
        let cursize = substitute(&gfn, font_pattern, '\2', '')
        let newsize = cursize + a:amount
        if (newsize >= min_sz) && (newsize <= max_sz)
            let newfont = oldfont . ':h' . newsize
            let &gfn = newfont
        endif
    else
        echoerr "This only works in a gui"
    endif
endfunction
