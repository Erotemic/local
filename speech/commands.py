#from dragonfly import *  # noqa
import dragonfly as fly
from _crall_dragonfly import esc, CtrlAlt, CtrlShift, release  # *  # NOQA
from _python import python_mapping
from _vimedit import vim_mapping

# Here we define the *default* command map.  If you would like to
#  modify it to your personal taste, please *do not* make changes
#  here.  Instead change the *config file* called '_multiedit.txt'.

# Spoken-form    ->    ->    ->     Action object

my_vocab = [
    'cache',
    'dir',
]


words = {
    'vim': fly.Text('vim'),
    'G. vim': fly.Text('gvim'),
    'pandas': fly.Text('pandas'),
    'notebook': fly.Text('notebook'),
    #'esc | ask': fly.Text('esc'),
}

terminal = {
    'lips | L. S.':  fly.Text('ls') + fly.Key('enter'),
}

_git = '(get | git)'
_git = 'git'
git = {
    _git + ' move': fly.Text('git move'),
    _git + ' status': fly.Text('git status'),
    _git + ' add': fly.Text('git add '),
    _git + ' commit': fly.Text('git commit -am ""') + fly.Key('left'),
    _git + ' push': fly.Text('git push'),
    _git + ' pull': fly.Text('git pull'),

    'G.G.P.': fly.Text('ggp'),
    'G.G.S.': fly.Text('ggs'),
    'G.C. wip' : fly.Text('gcwip'),
}

mapping = {
    'new (term | terminal)' : CtrlAlt(fly.Key('t')),
    'Q. T. C.'              : CtrlShift(fly.Text(':')),
    'term | terminal'       : fly.Key('w-c'),
    'save'                  : fly.Key('c-s'),
    'make template'         : fly.Text('o\'\'; Template(\'\'),'),
    'make fly.Key'          : fly.Text('o\'\'; fly.Key(\'\'),'),
    #'oink':              BringApp('gvim'),
    #'restart': Mimic('copy up one enter'),
    # space:%(n)d'),
    #'reboot': fly.Key('c-c, up, enter'),
}
mapping.update(vim_mapping)
mapping.update(python_mapping)
mapping.update(terminal)
mapping.update(words)
mapping.update(git)


namespace = {
    'Key':   fly.Key,
    'Text':  fly.Text,
}

#---------------------------------------------------------------------------
# Set up this module's configuration.

config = fly.Config('commands')
config.cmd = fly.Section('Language section')
config.cmd.map = fly.Item(
    mapping,
    namespace,
)
namespace = config.load()

#---------------------------------------------------------------------------
# Here we prepare the list of formatting functions from the config file.

# Retrieve text-formatting functions from this module's config file.
#  Each of these functions must have a name that starts with 'format_'.
format_functions = {}
if namespace:
    for name, function in namespace.items():
        if name.startswith('format_') and callable(function):
            spoken_form = function.__doc__.strip()

            # We wrap generation of the Function action in a function so
            #  that its *function* variable will be local.  Otherwise it
            #  would change during the next iteration of the namespace loop.
            def wrap_function(function):
                def _function(dictation):
                    formatted_text = function(dictation)
                    fly.Text(formatted_text).execute()
                return fly.Function(_function)

            action = wrap_function(function)
            format_functions[spoken_form] = action


# Here we define the text formatting rule.
# The contents of this rule were built up from the 'format_*'
#  functions in this module's config file.
if format_functions:
    class FormatRule(fly.MappingRule):

        mapping = format_functions
        extras = [fly.Dictation('dictation')]

else:
    FormatRule = None


class KeystrokeRule(fly.MappingRule):

    exported = False

    mapping = config.cmd.map
    extras = [
        fly.IntegerRef('n', 1, 100),
        fly.Dictation('text'),
    ]
    defaults = {
        'n': 1,
    }

alternatives = []
alternatives.append(fly.RuleRef(rule=KeystrokeRule()))
if FormatRule:
    alternatives.append(fly.RuleRef(rule=FormatRule()))
single_action = fly.Alternative(alternatives)

sequence = fly.Repetition(single_action, min=1, max=16, name='sequence')


class RepeatRule(fly.CompoundRule):

    # Here we define this rule's spoken-form and special elements.
    spec = '<sequence> [[[and] repeat [that]] <n> times]'
    extras = [
        sequence,                 # Sequence of actions defined above.
        fly.IntegerRef('n', 1, 100),  # Times to repeat the sequence.
    ]
    defaults = {
        'n': 1,                   # Default repeat count.
    }

    def _process_recognition(self, node, extras):
        sequence = extras['sequence']   # A sequence of actions.
        count = extras['n']             # An integer repeat count.
        for i in range(count):
            for action in sequence:
                action.execute()
        release.execute()


#---------------------------------------------------------------------------
# Create and load this module's grammar.

grammar = fly.Grammar('commands')   # Create this module's grammar.
grammar.add_rule(RepeatRule())    # Add the top-level rule.
grammar.load()                    # Load the grammar.

# Unload function which will be called at unload time.


def unload():
    global grammar
    if grammar:
        grammar.unload()
    grammar = None
