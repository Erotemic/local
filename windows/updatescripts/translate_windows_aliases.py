from __future__ import absolute_import, division, print_function
from os.path import join, expanduser, exists, normpath
import re
import sys

VERBOSE = '--verbose' in sys.argv
FORCE = '--force' in sys.argv


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


def read_lines(fpath):
    with open(fpath, 'r') as file_:
        line_list = file_.readlines()
    return line_list


def parse_bash_script(fpath):
    line_list = read_lines(fpath)
    parent = []
    parse_tree_root = []
    parse_tree = parse_tree_root
    line_iter = enumerate(line_list)
    def get_next_line():
        count, line = line_iter.next()
        return count, line.strip('\n')

    # Read each line in the bash rc file
    while True:
        try:
            count, line = get_next_line()
        except StopIteration:
            break
        # Skip comments
        try:
            if re.search('^ *#', line) or re.search('^$', line):
                continue
            elif re.search('^ *alias', line):
                line = re.sub('^ *alias', '', line)
                eqpos = line.find('=')
                alias_name = line[0:eqpos].strip(' ')
                alias_cmd = line[eqpos + 1:].strip('\'').strip(' ')
                parse_tree.append(('alias', alias_name, alias_cmd))
                #print(line)
            elif re.search('^ *[a-zA-Z0-9_\\-]+\(\) *$', line):
                # Begin function
                count, next_line = get_next_line()
                if next_line != '{':
                    raise Exception("expected {. got: %r" % next_line)
                func_name = re.sub('\(\) *$', '', line)
                parent.append(parse_tree)
                func_tree = []
                parse_tree.append(('func', func_name, func_tree))
                parse_tree = func_tree
            elif re.search('^ *[a-zA-Z0-9_\\-]+\(\) *{ *$', line):
                # Begin function
                func_name = re.sub('\(\) *{ *$', '', line)
                parent.append(parse_tree)
                func_tree = []
                parse_tree.append(('func', func_name, func_tree))
                parse_tree = func_tree
            # End of function
            elif re.search('^ *} *$', line):
                parse_tree = parent.pop()
            else:
                parse_tree.append(('cmd', line))
        except Exception as ex:
            print(ex)
            print('Failed parsing line#=%r' % count)
            print('Failed parsing line=%r' % line)
            raise
    #print('\n'.join(map(str, parse_tree)))
    return parse_tree_root


def translate_cmd_bash_to_batch(command):
    #print('+ convert: %r' % (command,))
    # Translate home directory
    command = re.sub('~', '%USERPROFILE%', command)
    # Translate variable names
    command = re.sub(r'\$([a-zA-Z_]*)', r'%\1%', command)
    # Replace single with double quotes
    command = command.replace('\'', '"')
    #print('L --> : %r' % (command,))
    return command


def translate_rc(rc_fpath):
    print('Translating: rc_fpath=%r' % rc_fpath)
    parse_tree_root = parse_bash_script(rc_fpath)
    #print('\n'.join(map(str, parse_tree_root)))
    invalid_commands = ['..', 'lls', 'wget', 'l', 'ls', 'rrr', 'upp',
                        'cop', 'src', 'rob', 'scr']
    for tup in parse_tree_root:
        type_ = tup[0]
        # Convert parsed aliases
        if type_ in ['alias']:
            alias_name = tup[1]
            if VERBOSE:
                print('ALIAS name=%r' % alias_name)
            alias_cmd = tup[2]
            bat_fpath = normpath(join(winscript_dir, alias_name + '.bat'))
            if alias_name in invalid_commands:
                if VERBOSE:
                    print('   ...invalid')
                #print('invalid command: %s' % alias_name)
                continue
                pass
            if exists(bat_fpath) and not FORCE:
                if VERBOSE:
                    print('   ...up to date')
                continue
                pass
            print('   ...TRANSLATING')
            batcommand = translate_cmd_bash_to_batch(alias_cmd)
            # append all arguments to end of alias
            batcommand += ' %*'
            print(bat_fpath)
            with open(bat_fpath, 'w') as file_:
                file_.write(batcommand)
            #print(batcommand)
        # Convert parsed functions
        elif type_ in ['func']:
            func_name = tup[1]
            if VERBOSE:
                print('FUNC name=%r' % func_name)
            func_cmds = tup[2]
            bat_fpath = normpath(join(winscript_dir, func_name + '.bat'))
            if func_name in invalid_commands:
                if VERBOSE:
                    print('   ...invalid func')
                continue
            if exists(bat_fpath) and not FORCE:
                if VERBOSE:
                    print('   ...up to date func')
                continue
                pass
            print('   ...TRANSLATING')
            batcommand = '\n'.join(
                [translate_cmd_bash_to_batch(cmdtup[1])
                 for cmdtup in func_cmds]
            )
            print(bat_fpath)
            with open(bat_fpath, 'w') as file_:
                file_.write(batcommand)
            pass
        else:
            print('type_ = %r' % type_)
            print('tup = %r' % (tup,))

if __name__ == '__main__':
    winscript_dir = expanduser('~/local/windows/scripts')
    local_dir = expanduser('~/local')
    TRANSLATE_FILES = map(normpath, [
        join(local_dir, 'alias_rc.sh'),
        join(local_dir, 'git_helpers.sh')
    ])

    for rcfname in TRANSLATE_FILES:
        assert exists(rcfname)
        translate_rc(rcfname)
