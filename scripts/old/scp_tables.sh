scp_pull_hotspotter_tables()
{
    
    export dbname='GZ_ALL'
    export remote='joncrall@hyrule.cs.rpi.edu'
    export src=data/work/$dbname
    export dst=/d/data/work/$dbname
    echo "Moving HotSpotter dbname=$dbname from remote=$remote"
    # -p creates all parents (--parents on ubuntu)
    echo "Copy tables"
    scp $remote:$src/_hsdb/image_table.csv $dst/_hsdb/
    scp $remote:$src/_hsdb/name_table.csv  $dst/_hsdb/
    scp $remote:$src/_hsdb/chip_table.csv  $dst/_hsdb/
}
    
}
export dbname='GZ_ALL'
export remote='joncrall@hyrule.cs.rpi.edu'
scp_pull_hotspotter_tables
