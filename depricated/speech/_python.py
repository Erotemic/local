import dragonfly as fly
from _crall_dragonfly import Template
from _python_templates import func_tfmt, class_tfmt, listcomp_fmt

python_mapping = {
    'F. M. T.': fly.Text('fmt'),
    'P. Y.': fly.Text('py'),
    'N. P.': fly.Text('np'),
    'P. D.': fly.Text('pd'),
    'triple quote': fly.Text('\'\'\'') + fly.Key('enter') + fly.Text('\'\'\''),
    'is instance' : fly.Text('isinstance'),
    'U. tool' : fly.Text('utool'),
    'I. python' : fly.Text('ipython'),


    'from' : fly.Text('from '),
    'import' : fly.Text('import '),
    'lambda' : fly.Text('lambda '),
    'zip' : fly.Text('zip'),
    'map' : fly.Text('map'),

    #'import <mod>' : fly.Text('import /%(mod)s'),
    #'import <mod> as <alias>' : fly.Text('import /%(mod)s as /%(alias)s'),

    # common phrases

    'no Q. A.': fly.Text('  # NOQA'),

    # python structures

    'make def'    : Template(func_tfmt),
    'make class'  : Template(class_tfmt),
    'make string' : fly.Text('\'\''),
    'make list comprehension' : fly.Text(listcomp_fmt),

    # surround syntax

    'curl | curly | curling' : fly.Text('{}'),
    'brack | bracket'        : fly.Text('[]'),
    'paren | parentheses'    : fly.Text('()'),
    'L. brak': fly.Text('['),
    'L. curl': fly.Text('{'),
    'L. paren': fly.Text('('),
    'L. brak': fly.Text('['),
    'L. curl': fly.Text('{'),
    'L. paren': fly.Text('('),
}
