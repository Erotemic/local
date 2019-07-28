import os

flickr_api_key = os.environ.get('FLICKER_API_KEY')
flickr_api_secret = os.environ.get('FLICKR_API_SECRET')

def vd():
    os.system('vd')

#TODO: Steal code from hotspotter
def printableVal(val,type_bit=True):
    import numpy as np
    import types
    import re
    if type(val) is np.ndarray:
        info = npArrInfo(val)
        if info.dtypestr == 'bool':
            _valstr = '{ shape:'+info.shapestr+' bittotal: '+info.bittotal+'}'# + '\n  |_____'
        else:
            _valstr = '{ shape:'+info.shapestr+' mM:'+info.minmaxstr+' }'# + '\n  |_____'
    elif type(val) is types.StringType:
        _valstr = '\'%s\'' % val
    elif type(val) is types.ListType:
        if len(val) > 30:
            _valstr = 'Length:'+str(len(val))
        else:
            _valstr = '[\n'+('\n'.join([str(v) for v in val]))+'\n]'
    elif hasattr(val, 'get_printable') and type(val) != type: #WTF? isinstance(val, AbstractPrintable):
        _valstr = val.get_printable(type_bit=type_bit)
    elif type(val) is types.DictType:
        _valstr = '{\n'
        for val_key in val.keys():
            val_val = val[val_key]
            _valstr += '  '+str(val_key) + ' : ' + str(val_val)+'\n'
        _valstr += '}'
    else:
        _valstr = str(val)
    if _valstr.find('\n') > 0: # Indent if necessary
        _valstr = _valstr.replace('\n','\n    ')
        _valstr = '\n    '+_valstr
    _valstr = re.sub('\n *$','', _valstr) # Replace empty lines
    return _valstr



# PRINTS AN ELEMENT TREE
def parse_tree(element, indent=''):
    retstr   = ''
    children = element.getchildren()
    if len(children) > 0:
        retstr  += indent+'Element Tag: %r Num Children %d\n' % (element.tag, len(children))
    for (childx, child) in enumerate(children):
        retstr += parse_tree(child, indent='    '+indent)
    return retstr

# PRINTS A DETAILED ELEMENT TREE
def detailed_parse_tree(element, indent=''):
    retstr = ''
    retstr += (indent+'Element Type: %r ' % element.tag)
    retstr += (indent+'Element Text: %r ' % element.text)+'\n'
    #retstr += (indent+'Element Tail: %r ' % element.tail)
    items = {key:val for key, val in element.items()}
    retstr += (indent+'Element Tail: %r ' % items)+'\n'
    children = element.getchildren()
    for (childx, child) in enumerate(children):
        retstr += ('-'*len(indent)+'Child %2d ' % childx)+'\n'
        retstr += detailed_parse_tree(child, indent='    '+indent)
    return retstr
