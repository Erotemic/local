import functools


def dec(func):
    @functools.wraps(func)
    def wrap(*args, **kwargs):
        return func(*args, **kwargs)
    return wrap


@dec
def spam():
    print('I sure hope nobody throws an Exception')
    eggs()


@dec
def eggs():
    raise Exception('Spanish Inquisition')


if __name__ == '__main__':
    spam()
