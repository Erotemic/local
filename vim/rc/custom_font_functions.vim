func! ToggleFont() 
    if !exists("g:togfont") 
        let g:togfont=0
    endif
    python << endpython
import vim
togfont = int(vim.eval('g:togfont'))
vim.command('call SetFuzzyFont(%r)' % togfont)
vim.command('let g:togfont=%r' % (togfont + 1))
endpython
":ECHOVAR gfn
endfu 

fu! SetFuzzyFont(fontid)
python << endpython
def run_py_fuzzyfont():
    import vim
    import sys
    import Levenshtein  # Edit distance algorithm
    from operator import itemgetter
    request = vim.eval('a:fontid')
    win32_fonts = [
        r'Mono\ Dyslexic:h10',
        r'Inconsolata:h10',
        r'Inconsolata:h11',
        r'monofur:h11',
        #r'Source_Code_Pro:h11:cANSI',
        #r'peep:h11:cOEM',
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
        #r'MonoDyslexic\ 10',
        r'Inconsolata\ Medium\ 11',
        r'Inconsolata\ Medium\ 9',
        #r'Inconsolata\ Medium\ 10',
        r'Neep\ 11',
        r'monofur\ 11',
        r'White\ Rabbit\ 10',
        #r'Courier\ New\ 11',
        #r'Nimbus\ Mono\ L\ 11', 
        #r'Ubuntu\ Mono\ 9',
        #r'Neep\ Alt\ Medium\ Semi-Condensed\ 11'
    ]
    if sys.platform.startswith('win32'):
        known_fonts = win32_fonts
    else:
        known_fonts = linux_fonts

    def vimprint(message):
        vim.command(':silent !echom %r' % message)
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
run_py_fuzzyfont()
endpython
endfu


fu! SetMyFont()
    call SetFuzzyFont("monodyslexic")
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
