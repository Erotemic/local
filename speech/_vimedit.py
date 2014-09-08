from _crall_dragonfly import esc  # NOQA
import dragonfly as fly
# https://pythonhosted.org/dragonfly/actions.html#refkeyspecnames
key_mapping = {
    'A. | a'       : fly.Key('a'),
    'B.'           : fly.Text('b'),
    'I.'           : fly.Text('i'),
    'J.'           : fly.Text('j'),
    'K.'           : fly.Text('k'),
    'F.'           : fly.Text('f'),
    'O. | oh | o ' : fly.Text('o'),
    'R. '          : fly.Text('r'),
    'W. '          : fly.Text('w'),
    'Q. '          : fly.Text('q'),
}


#key_mapping = {
#    '(A. | a | alpha)'        : 'a',
#    '(B. | bravo) '           : 'b',
#    '(C. | charlie) '         : 'c',
#    '(D. | delta) '           : 'd',
#    '(E. | echo) '            : 'e',
#    '(F. | foxtrot) '         : 'f',
#    '(G. | golf) '            : 'g',
#    '(H. | hotel) '           : 'h',
#    '(I. | india | indigo) '  : 'i',
#    '(J. | juliet) '          : 'j',
#    '(K. | kilo) '            : 'k',
#    '(L. | lima) '            : 'l',
#    '(M. | mike) '            : 'm',
#    '(N. | november) '        : 'n',
#    '(O. | o | oh | oscar) '  : 'o',
#    '(P. | papa | poppa) '    : 'p',
#    '(Q. | quebec | quiche) ' : 'q',
#    '(R. | romeo) '           : 'r',
#    '(S. | sierra) '          : 's',
#    '(T. | tango) '           : 't',
#    '(U. | uniform) '         : 'u',
#    '(V. | victor) '          : 'v',
#    '(W. | whiskey) '         : 'w',
#    '(X. | x-ray) '           : 'x',
#    '(Y. | yankee) '          : 'y',
#    '(Z. | zulu) '            : 'z',
#}

symbol_mapping = {
    'pipe'              : fly.Text('|'),
    'plus'              : fly.Text('+'),
    'minus'             : fly.Text('-'),
    'love | under'      : fly.Text('_'),
    'equals'            : fly.Text('='),
    'care'              : fly.Text('^'),
    'doll'              : fly.Text('$'),
    'star | asterisk'   : fly.Text('*'),
    'comma'             : fly.Text(','),
    'percent'           : fly.Text('%%'),
    'slash':  fly.Text('/'),
    'backslash':  fly.Text('\\'),
    'dot'               : fly.Text('.'),
}

vim_nav = {
    'to pipeline | open pipeline'     : esc + fly.Text(';Topipeline'),
    'open here'         : esc + fly.Text(';e .') + fly.Key('enter'),
}

vim_other = {
    'control R. control W.': fly.Key('c-r') + fly.Key('c-w'),
}


repel = '(repl | rebel | replace)'

vim_leader = {
    'comment'           : fly.Text(',c '),
    repel + ' here'  : esc + fly.Text(',ss'),
}

vim_commands = {
    repel    : esc + fly.Text(';%%s///gc') + fly.Key('left:4'),
    repel + ' line'    : esc + fly.Text(';s///gc') + fly.Key('left:4'),
    'split'             : fly.Text(';split') + fly.Key('enter'),
    'V. split'          : fly.Text(';vsplit') + fly.Key('enter'),
    'align'             : fly.Text(';Align'),
}

vim_mapping = {
    'D. D.'             : esc + fly.Text('dd'),
    'yank'              : esc + fly.Text('yy'),
    'dupe | duplicate'  : esc + fly.Text('yyp'),
    'change word'       : esc + fly.Text('cw'),
    'delete word'       : esc + fly.Text('dw'),
    'unfold'            : esc + fly.Text('zR'),
    'visual'            : fly.Key('V'),
    'ask'               : fly.Key('escape'),
    'search <text>'     : esc + fly.Text('/%(text)s'),
    'sem | semi | some' : fly.Text(';'),
    #'indent [<n>]':                     Key('>:%(n)d')
    #'unindent [<n>]':                   Key('<:%(n)d')
}
vim_mapping.update(key_mapping)
vim_mapping.update(symbol_mapping)
vim_mapping.update(vim_nav)
vim_mapping.update(vim_other)
vim_mapping.update(vim_leader)
vim_mapping.update(vim_commands)


vim_context = fly.AppContext(executable="gvim")
