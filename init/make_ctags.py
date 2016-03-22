
import utool as ut
import re

vim = 0
SLASH = re.escape('\\')
LCURL = re.escape(r'{')
RCURL = re.escape(r'}')
NOT_LCURL = '[^}]'
NOPREV_LCURL = ut.negative_lookbehind(r'{', vim=1)
ANY_NONGREEDY = '.' + ut.nongreedy_kleene_star(vim=vim)
NONEXT_BSLASH = ut.negative_lookahead(SLASH, vim=vim)


def GROUP(x):
    return '(' + x + ')'

title = 'section'

tks = [
    ('section', 's'),
    ('subsection', 't'),
    ('subsubsection', 'u'),
]

print('--langdef=tex')
print('--langmap=tex:.tex')
# --regex-tex=/\\label\{([^}]*)\}/\1/l,label/

# --regex-tex=/\\label\{([^}]*)\}/\1/l,label/
# --regex-tex=/^\s*\\section\{([^}]*)\}/\1/s,section/
# --regex-tex=/^\s*\\subsection\{([^}]*)\}/\1/t,subsection/
for title, kind in tks:
    if title == 'section':
        # exp = '^\s*' + SLASH + title + LCURL + GROUP('.*') + RCURL + NONEXT_BSLASH
        # ctagline = '--regex-tex=/' + exp + r'/\1/' + kind + ',' + title + '/'
        # print(ctagline)
        exp = '^\s*' + SLASH + title + LCURL + GROUP(NOT_LCURL + '*') +  RCURL
        ctagline = '--regex-tex=/' + exp + r'/\1/' + kind + ',' + title + '/'
        print(ctagline)
    else:
        exp = '^\s*' + SLASH + title + LCURL + GROUP(NOT_LCURL + '*') + RCURL
        ctagline = '--regex-tex=/' + exp + r'/\1/' + kind + ',' + title + '/'
        print(ctagline)
