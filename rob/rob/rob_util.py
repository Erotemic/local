
def cast(var, type_):
    if type_ is bool:
        if var is True or var in ['true', 'True']:
            return True
        elif var is False or var in ['false', 'False']:
            return False
        else:
            raise ValueError('cannot cast')
