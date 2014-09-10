import os
import fnmatch

def find_files(directory, pattern):
    for root, dirs, files in os.walk(directory):
        for basename in files:
            if fnmatch.fnmatch(basename, pattern):
                filename = os.path.join(root, basename)
                yield filename

for fname in find_files('.', 'CMakeLists.txt'):
    f = open(fname,'a')
    f.write('\ninclude_directories(${OPENGL_INCLUDE_PATH} ${GLUT_INCLUDE_PATH})')
    f.close()

