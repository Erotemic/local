import sys
import os
PATH = os.getenv('PATH')
#PATH = sys.argv[1]
for line in PATH.split(';'):
    print line
