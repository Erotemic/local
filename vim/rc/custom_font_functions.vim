

function! ToggleFont(...) 
Python2or3 << endpython3
import vim
#import sys
#print(sys.version_info)
#print(sys.prefix)
#print(sys.executable)
# We got this weirdness at one point
# not sure why sys.version was 3.8.5, but exe was 3.9.2
#sys.version_info(major=3, minor=8, micro=5, releaselevel='final', serial=0)
#/home/joncrall/.pyenv/versions/3.9.2/envs/py39
#/home/joncrall/.pyenv/versions/3.9.2/envs/py39/bin/python3

def python_toggle_font():
    import vim
    import pyvim_funcs
    hasindex = int(vim.eval('exists("g:myfontindex")')) != 0
    increment = int(vim.eval('a:1'))
    if hasindex: 
        if increment == 0:
            return
        orig_myfontindex = int(vim.eval('g:myfontindex'))
    else:
        orig_myfontindex = 0
    myfontindex = orig_myfontindex + increment
    vim.command('let g:myfontindex=%r' % (myfontindex))
    try:
        pyvim_funcs.pyrun_fuzzyfont(myfontindex)
    except Exception as ex:
        msg = 'error in togglefont(%r): %r %s' % (myfontindex, type(ex), str(ex),)
        vim.command(':echom %r' % (msg,))
python_toggle_font()
endpython3
endfunction


function! SetFuzzyFont(fontid)
Python2or3 << endpython3
import sys
print(sys.version_info)
import pyvim_funcs
request = vim.eval('a:fontid')
pyvim_funcs.pyrun_fuzzyfont(request)
endpython3
endfunction


function! FontDecrease()
    call AdjustFontSize(-1)
endfunction
command! FontDecrease call FontDecrease()


function! FontMenu()
Python2or3 << endpython3
import pyvim_funcs
#import imp
#imp.reload(pyvim_funcs)
known_fonts = pyvim_funcs.available_fonts()
request = pyvim_funcs.vim_popup_menu(known_fonts)
pyvim_funcs.pyrun_fuzzyfont(request)
endpython3
"http://stackoverflow.com/questions/13537521/custom-popup-menu-in-vim
endfunction


function! FontIncrease()
    call AdjustFontSize(1)
endfunction
command! FontIncrease call FontIncrease()

" NEW QUICK INCREASE FONT STUFF
function! AdjustFontSize(amount)
let oldgfn=&gfn
Python2or3 << endpython3
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
        if sepx2 == -1:
            sepx2 = None
        font_name = gfn[:sepx] + ':h'
        sl = slice(sepx + 2, sepx2)
        try:
            substr = gfn[sl]
            font_size = float(substr)
        except Exception:
            pass
        font_suff = gfn[sepx2:] if sepx2 is not None else ''
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
endpython3
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
