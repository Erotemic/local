#from dragonfly import *  # noqa
import dragonfly as fly
import six


def MultiAction(action_iter):
    action_iter = iter(action_iter)
    action = six.next(action_iter)
    for next_action in action_iter:
        action += next_action
    return action


def Hold(*keys):
    #return fly.Key(', '.join([key + ':down' for key in keys]))
    key_iter = (fly.Key(key + ':down') for key in keys)
    return MultiAction(key_iter)


def Release(*keys):
    #return fly.Key(', '.join([key + ':up' for key in keys]))
    key_iter = (fly.Key(key + ':up') for key in keys)
    return MultiAction(key_iter)


def CtrlAlt(action):
    return Hold('ctrl', 'alt') + action + Release('ctrl', 'alt')


def CtrlShift(action):
    return Hold('ctrl', 'shift') + action + Release('ctrl', 'shift')


def Template(fmt):
    return fly.Text(fmt)

release = Release('shift', 'ctrl')  # Key('shift:up, ctrl:up')
esc = fly.Key('escape')
