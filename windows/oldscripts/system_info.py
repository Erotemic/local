import platform
import struct
import sys
print('Platform architecture: ')
print(platform.architecture())
print('bits per instruction: '+ str(8 * struct.calcsize("P")))
print('Int Maxsize: '+str(sys.maxsize))
print('2^32 =       '+str( 2**32))
print('2^64 =       '+str( 2**64))

#install_prefix   = 'C:/Program Files (x86)'
#print('Progam Files (x86)? : '+str('PROGRAMFILES(X86)' in os.environ))
#for key, val in os.environ.iteritems():
    #print(key+' = '+str(val))

