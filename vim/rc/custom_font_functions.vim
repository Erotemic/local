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
    call SetFuzzyFont(g:togfont)
endfu 

fu! SetFuzzyFont(fontid)
python << endpython
import vim
import sys
import Levenshtein  # Edit distance algorithm
from operator import itemgetter
request = vim.eval('a:fontid')
win32_fonts = [
    r'Mono\ Dyslexic:h10',
    r'Inconsolata:h10',
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
    #r'Ubuntu\ Mono\ 9',
    #r'Neep\ Alt\ Medium\ Semi-Condensed\ 11'
]
if sys.platform.startswith('win32'):
    known_fonts = win32_fonts
else:
    known_fonts = linux_fonts

def vimprint(message):
    #vim.command(':silent !echom %r' % message)
    #vim.command(':echom %r' % message)
    pass

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
endfu


fu! SetMyFont()
    call SetFuzzyFont("monodyslexic")
    "call SetFontDyslexic()
    "call SetFontClean()
endfu


" Setting Font Functions
fu! SetFontClean()
    if has("win32") || has("win16")
        call SetFuzzyFont("Inconsolata")
    else
        set gfn=Neep\ 11
    endif
endfu


" Setting Font Functions
fu! SetFontDyslexic()
    if has("win32") || has("win16")
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
