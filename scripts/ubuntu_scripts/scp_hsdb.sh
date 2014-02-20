#/bin/bash

scp_hotspotter_database()
{
    export dbname=$1
    export remote=$2
    export src=~/data/work/$dbname
    export dst=data/work/$dbname
    echo "Moving HotSpotter dbname=$dbname to remote=$remote"
    # -p creates all parents (--parents on ubuntu)
    ssh $remote "mkdir -p $dst/_hsdb" 
    echo "Copy images"
    scp -r $src/images $remote:$dst/images
    echo "Copy tables"
    echo scp $src/_hsdb/image_table.csv $remote:$dst/_hsdb/
    echo scp $src/_hsdb/name_table.csv  $remote:$dst/_hsdb/
    echo scp $src/_hsdb/chip_table.csv  $remote:$dst/_hsdb/
}

#export dbname='NAUT_Dan'
#export dbname='GZ_ALL'
export dbname='HSDB_zebra_with_mothers'
export remote='joncrall@longerdog.com'
scp_hotspotter_database $dbname $remote
#scp_hotspotter_database $@
