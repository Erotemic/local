#!/bin/bash

# This works pretty well
#du -h --max-depth=2

# NOt as well
# tree -h -L 2

bash_noop()
{
    export NOTHINGVAR=""
}

print_dirsize()
{
    export DIRSIZE=$(du -sh "$1")
    echo "$2$DIRSIZE"
}
print_filesize()
{
    bash_noop
    #export FILESIZE=$(du -sh "$1")
    #echo "$2$FILESIZE"
}

report_size1_func()
{
    for DNAME1 in $@
    do 
        #echo $DNAME
        if [ -d "$DNAME1" ] ; then
            # Report directory sizes sizes
            print_dirsize "$DNAME1" "    "
        else
            # Report file sizes
            print_filesize "$DNAME1" "    "
        fi
    done
}


report_size_func()
{
    for DNAME in $@
    do 
        if [ -d "$DNAME" ] ; then
            # Report directory sizes sizes
            print_dirsize "$DNAME"
            #report_size1_func "$DNAME/*"
        else
            # Report file sizes
            print_filesize "$DNAME"
        fi
    done
}

report_size_func *
