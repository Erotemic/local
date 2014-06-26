func! ToggleFont() 
    if !exists("g:togfont") 
        let g:togfont=0
    endif
    python << endpython
import vim
togfont = int(vim.eval('g:togfont'))
try:
    vim.command('call SetFuzzyFont(%r)' % togfont)
except Exception as ex:
    msg = "error in togglefont(%r): %r %s" % (togfont, type(ex), str(ex),)
    vim.command(':echom %r' % (msg,))
    pass
vim.command('let g:togfont=%r' % (togfont + 1))
endpython
":ECHOVAR gfn
endfu 

fu! SetFuzzyFont(fontid)
python << endpython
def pyrun_fuzzyfont():
    import vim
    import sys
    from operator import itemgetter
    request = vim.eval('a:fontid')
    win32_fonts = [
        r'Mono_Dyslexic:h10:cANSI',
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
    win32_alts = {
        'monodyslexic': [r'Mono_Dyslexic:h10:cANSI']
    }
    linux_fonts = [
        r'MonoDyslexic\ 9.4',
        r'Inconsolata\ Medium\ 11',
        r'Inconsolata\ Medium\ 9',
        r'Neep\ 11',
        r'monofur\ 11',
        r'White\ Rabbit\ 10',
    ]
    linux_extended = [
        r'MonoDyslexic\ 10',
        r'Inconsolata\ Medium\ 10',
        r'Courier\ New\ 11',
        r'Nimbus\ Mono\ L\ 11', 
        r'Ubuntu\ Mono\ 9',
        r'Neep\ Alt\ Medium\ Semi-Condensed\ 11'
        ]
    #linux_fonts = sorted(linux_fonts + linux_extended)
    if sys.platform.startswith('win32'):
        known_fonts = win32_fonts
    else:
        known_fonts = linux_fonts

    def vimprint(message):
        # this doesnt even work #vim.command(':silent !echom %r' % message)
        #vim.command(':echom %r' % message)
        pass

    vimprint('request=%r %r' % (type(request), request))

    int_str = map(str, range(0, 9))
    is_integer_str = all([_ in int_str for _ in request])
        
    if isinstance(request, (str)) and not is_integer_str:
        # Calcualate edit distance to each known font
        try:
            import Levenshtein  # Edit distance algorithm
        except ImportError as ex:
            vim.command(":echom 'error no python module Levenshtein'")
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
pyrun_fuzzyfont()
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
let oldgfn=&gfn
python << endpython
def pyrun_adjust_size():
    import vim
    import sys
    def vimprint(message):
        vim.command(':silent !echom %r' % message)
        #vim.command(':echom %r' % message)
        pass
    amount = int(vim.eval('a:amount'))
    vimprint(amount)
    gfn = vim.eval('oldgfn')
    if sys.platform.startswith('win32'):
        #font_name, font_size, extra = 
        pass
    else:
        sepx = gfn.rfind(' ')
        if sepx > -1:
            font_name = gfn[:sepx]
            font_size = float(gfn[sepx + 1:])
        else:
            font_size = 10
            font_name = gfn
        vimprint('font_name1 = %r' % font_name)
        font_name = font_name.replace('\\ ', ' ')
        if not font_name.endswith(' '):
            font_name = font_name + ' '
        vimprint('font_name2 = %r' % font_name)
        vimprint('gfn = %r' % gfn)
        vimprint('sepx = %r' % sepx)
        new_size = int(min(max(font_size + amount, 6), 16))
        new_gfn = font_name + str(new_size)
        new_gfn = new_gfn.replace(' ', r'\ ')
        vimprint('new_size = %r' % new_size)
        vimprint('new_gfn = %r' % new_gfn)
    vimprint(new_gfn)
    vim.command('set gfn=' + new_gfn)
pyrun_adjust_size()
endpython
    "                     part1       part2      part3
    "let font_pattern = '^\(.*\):h\([0-9][0-9]*\)\(.*$\)'
    "let min_sz = 6
    "let max_sz = 16
    "if has("gui_running")
    "    let oldfont = substitute(&gfn, font_pattern, '\1', '')
    "    let cursize = substitute(&gfn, font_pattern, '\2', '')
    "    let newsize = cursize + a:amount
    "    if (newsize >= min_sz) && (newsize <= max_sz)
    "        let newfont = oldfont . ':h' . newsize
    "        let &gfn = newfont
    "    endif
    "else
    "    echoerr "This only works in a gui"
    "endif
endfunction
