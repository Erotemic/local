#!/usr/bin/env python
portmap = {
    '\<guitools\>': 'guitool',
    '\<hs\>': 'ibs',
    '\<cx\>': 'cid',
    '\<gx\>': 'gid',
    '\<nx\>': 'nid',
}


def vim_repl_str(key, val):
    return '%s/' + key + '/' + val + '/gc'


def rob_repl_str(key, val):
    return 'rob sed ' + key + '/' + val + ' False True'

for key, val in portmap.iteritems():
    print(vim_repl_str(key, val))


'''
%s/slot_(\([^)]*\))\n *@blocking/blocking_slot(\1)/gc


'''
