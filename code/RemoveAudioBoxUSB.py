# http://support.presonus.com/entries/21524610-How-do-I-uninstall-and-reinstall-my-AudioBox-drivers-in-Windows-7-Vista-
# http://www.presonus.com/support/downloads/AudioBox-USB

import os
import types

def vd(dir):
    os.system('explorer "'+dir+'"')

def search(dir, search_strs):
    found_list = []
    print(' * Searching in %r' % dir)
    if type(search_strs) == types.StringType:
        search_strs = [search_strs]
    search_strs = [sstr.lower() for sstr in search_strs]
    print('... ... for %r ' % search_strs)
    sys.stdout.flush()
    for root, dirs, files in os.walk(dir):
        for name in dirs+files:
            nameL = name.lower()
            sstr2 = sstr.lower()
            FOUND_ANY=any([nameL.find(sstrL) != -1 for sstrL in search_strs])
            if FOUND_ANY:
                found_path = os.path.join(root,name)
                found_list += [found_path]
                found_type = ['dir','file'][os.path.isfile(found_path)]
                print('...  + Found '+found_type+' '+found_path)
                sys.stdout.flush()
    if len(found_list) == 0 :
        print('... ...nothing found')
        sys.stdout.flush()
    return found_list

#---------------
# Uninstall the driver application 
#---------------

#---------------
search_strs = ['AudioBox', 'PreSonus']

check_dirs  = [
    'C:/Program Files',
    'C:/Program Files (x86)',
    os.environ['APPDATA'],
    os.environ['SystemRoot']
]

all_found = []
for dir in check_dirs:
    all_found += search(dir, search_strs)

for dir in check_dirs:
    all_found += search(dir, 'audio')


if len(all_found) == 0:
    print('Nothing in the entire system!')
else:
    print('Found: ')
    for found in all_found:
        print found
# Remove C:\Program Files\PreSonus
# Remove C:\Program Files (x86)\PreSonus

# Add Envirornment Variable: 
# devmgr_show_nonpresent_devices = 1

#---------------
# Removing Device Manager Entries
#---------------


# Open Device Manager
os.environ['devmgr_show_nonpresent_devices'] = '1'
os.system('devmgmt.msc')

# view hidden devices

# check in: 
check_in = ['Other Devices',
            'PreSonus USB 2.0 Audio Devices',
            'Sound, Video, and Game Controllers',
            'Universal Serial Bus Controllers']
# Right click / uninstall any of the following: 
uinstall_devices = ['AudioBox',
                    'USB Audio Device', 
                    'Unknown Device']

#------------------
# Removing Application "Roaming" Data
#------------------

vd('%APPDATA%')
# open PreSonus folder
# Locate the folder in ['AudioBox', 'AudioBox VSL']


#------------------
# Removing Removing Data
#------------------
vd('%SystemRoot%')
# locate any files with AudioBox in the title and delete them

#Note: There may be other PreSonus prefetch data in this folder from
#Studio One or other PreSonus devices. Even if a file states PreSonus in the
#title, only delete it if it also states AudioBox!

#------------------
# Install the driver
#------------------

# Run installer as administrator
# Continue until it asks you to plug in device
# Plug in to a USB 2.0 Port
# Wait until bubble says: 
#   Device driver software was not successfully installed

# Click Install Driver
