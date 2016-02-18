func! ToggleFont(...) 
python << endpython
import vim
def python_toggle_font():
    import vim
    import pyvim_funcs
    hasindex = int(vim.eval('exists("g:myfontindex")')) != 0
    increment = int(vim.eval('a:1'))
    #print('hasindex = %r' % (hasindex,))
    if hasindex: 
        if increment == 0:
            # early exit
            return
        orig_myfontindex = int(vim.eval('g:myfontindex'))
    else:
        orig_myfontindex = 0
    myfontindex = orig_myfontindex + increment
    vim.command('let g:myfontindex=%r' % (myfontindex))
    #print('orig_myfontindex = %r' % (orig_myfontindex,))
    #print('increment = %r' % (increment,))
    #print('myfontindex = %r' % (myfontindex,))
    try:
        pyvim_funcs.pyrun_fuzzyfont(myfontindex)
    except Exception as ex:
        msg = 'error in togglefont(%r): %r %s' % (myfontindex, type(ex), str(ex),)
        vim.command(':echom %r' % (msg,))
python_toggle_font()
endpython
":ECHOVAR gfn
endfu 

fu! SetFuzzyFont(fontid)
python << endpython
import pyvim_funcs
request = vim.eval('a:fontid')
pyvim_funcs.pyrun_fuzzyfont(request)
endpython
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
        #vim.command(':silent !echom %r' % message)
        #vim.command(':echom %r' % message)
        pass
    amount = int(vim.eval('a:amount'))
    vimprint(amount)
    gfn = vim.eval('oldgfn')
    WIN32 = sys.platform.startswith('win32')
    if WIN32:
        # HACKY HACKY HACK
        #font_name, font_size, extra = 
        sepx = gfn.rfind(':h')
        sepx2 = gfn.rfind(':cANSI')
        font_name = gfn[:sepx] + ':h'
        font_size = float(gfn[sepx + 2:sepx2])
        font_suff = gfn[sepx2:] if sepx2 != -1 else ''
        pass
    else:
        # Find the position that seprates the font name 
        # from the font size
        sepx = gfn.rfind(' ')
        font_suff = ''  # no suffix on linux
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
    vimprint('font_name = %r' % font_name)
    vimprint('gfn = %r' % gfn)
    vimprint('sepx = %r' % sepx)
    new_size = int(min(max(font_size + amount, 6), 16))
    new_gfn = font_name + str(new_size) + font_suff
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
