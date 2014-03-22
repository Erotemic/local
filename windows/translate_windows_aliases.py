from os.path import join, expanduser, exists, normpath
import re


def read_lines(fpath):
    with open(fpath, 'r') as file_:
        line_list = file_.readlines()
    return line_list


def parse_bash_script(fpath):
    #import sys
    #import antlr3
    #from antlr3 import *
    #from ExprLexer import ExprLexer
    #from ExprParser import ExprParser

    # test the parser with an input
    #char_stream = antlr3.ANTLRStringStream('3+5\n')
    #lexer = ExprLexer(char_stream)
    #tokens = antlr3.CommonTokenStream(lexer)
    #parser = ExprParser(tokens)

    # print the parse tree
    #t = parser.expr().tree
    #print t.toStringTree()
    #return None

    #import shlex
    #with open(fpath, 'r') as file_:
        #sh = (shlex.shlex(file_))
        #print(sh.read_token())
        #print(sh.read_token())
        #print(sh.read_token())
        #print(sh.read_token())
        #print(sh.read_token())
        #print(sh.read_token())
        #print(sh.read_token())
        #print(sh.read_token())
        #print(sh.read_token())
        ##sh = (shlex.split(file_))
    #print(sh)

#def fm():
    line_list = read_lines(fpath)
    parent = []
    parse_tree_root = []
    parse_tree = parse_tree_root
    line_iter = enumerate(line_list)
    def get_next_line():
        count, line = line_iter.next()
        return count, line.strip('\n')

    while True:
        try:
            count, line = get_next_line()
        except StopIteration:
            break
        # Skip comments
        if re.search('^ *#', line) or re.search('^$', line):
            continue
        elif re.search('^ *alias', line):
            line = re.sub('^ *alias', '', line)
            eqpos = line.find('=')
            alias_name = line[0:eqpos].strip(' ')
            alias_cmd = line[eqpos + 1:].strip('\'').strip(' ')
            parse_tree.append(('alias', alias_name, alias_cmd))
            #print(line)
        elif re.search('^ *[a-zA-Z0-9_]+\(\) *$', line):
            count, next_line = get_next_line()
            if next_line != '{':
                raise Exception("expected {. got: %r" % next_line)
            func_name = re.sub('\(\) *$', '', line)
            parent.append(parse_tree)
            func_tree = []
            parse_tree.append(('func', func_name, func_tree))
            parse_tree = func_tree
        elif re.search('^ *[a-zA-Z0-9_]+\(\) *{ *$', line):
            func_name = re.sub('\(\) *{ *$', '', line)
            parent.append(parse_tree)
            func_tree = []
            parse_tree.append(('func', func_name, func_tree))
            parse_tree = func_tree
        elif re.search('^ *} *$', line):
            parse_tree = parent.pop()
        else:
            parse_tree.append(('cmd', line))
    #print('\n'.join(map(str, parse_tree)))
    return parse_tree_root


def translate_cmd_bash_to_batch(command):
    command = re.sub('~', '%USERPROFILE%', command)
    command = re.sub(r'\$([a-zA-Z_]*)', r'%\1%', command)
    return command


def translate_alias_rc():
    winscript_dir = expanduser('~/local/windows/scripts')
    local_dir = expanduser('~/local')
    aliasrc_fname = 'alias_rc.sh'
    aliasrc_fpath = join(local_dir, aliasrc_fname)
    parse_tree_root = parse_bash_script(aliasrc_fpath)
    #print('\n'.join(map(str, parse_tree_root)))
    invalid_commands = ['..', 'lls', 'wget', 'l', 'ls', 'rrr', 'upp', 'cop']
    for tup in parse_tree_root:
        type_ = tup[0]
        if type_ == 'alias':
            alias_name = tup[1]
            alias_cmd = tup[2]
            if alias_name in invalid_commands:
                print('invalid command: %s' % alias_name)
                continue
            bat_fpath = normpath(join(winscript_dir, alias_name + '.bat'))
            if exists(bat_fpath):
                #print('already have: %s' % bat_fpath)
                continue
            batcommand = translate_cmd_bash_to_batch(alias_cmd)
            print(bat_fpath)
            with open(bat_fpath, 'w') as file_:
                file_.write(batcommand)
            #print(batcommand)

if __name__ == '__main__':
    translate_alias_rc()
