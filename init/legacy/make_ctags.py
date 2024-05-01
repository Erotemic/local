
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

#tks = [
#    ('section', 's'),
#    ('subsection', 't'),
#    ('subsubsection', 'u'),
##]

#print('--langdef=tex')
#print('--langmap=tex:.tex')
# --regex-tex=/\\label\{([^}]*)\}/\1/l,label/

# --regex-tex=/\\label\{([^}]*)\}/\1/l,label/
# --regex-tex=/^\s*\\section\{([^}]*)\}/\1/s,section/
# --regex-tex=/^\s*\\subsection\{([^}]*)\}/\1/t,subsection/
tks = [
    'chapter',
    'section',
    'subsection',
    'subsubsection',
    'paragraph'
]
LANG = 'tex2'
"""
python ~/local/init/make_ctags.py
"""

begin_part = ut.codeblock(
    r'''
    --exclude=.git

    --langdef=tex2
    --langmap=tex2:.tex

    --regex-tex2=/\\label\s*\{([^}]+)\}/\1/l,label/
    --regex-tex2=/\\cref\s*\{([^}]+)\}/\1/r,ref/
    ''')

print(begin_part + '\n')
for num, title in enumerate(tks):
    base = '^\s*' + SLASH + title + r'\s*' + LCURL + GROUP('[^:]*') + RCURL
    regexp_list = [
        base + '$',
        base + r'[:]*\\label'
    ]
    replpart = '+' + '-' * (2 * num) + r' \1'
    kindpart = 'p,' + title
    for regexp in regexp_list:
        print('--regex-' + LANG + '=/' + regexp + '/' + replpart + '/' + kindpart + '/' )
