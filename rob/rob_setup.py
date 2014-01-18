def dev_backup_settings(r):
    'Shouldnt run this very often and only on BakerStreet'
    if 0:
        import distutils.dir_util
        for (LOCAL_DIR, CLOUD_DIR) in r.symlink_local_cloud:
            print " * Backing Up "+LOCAL_DIR+" to "+CLOUD_DIR
            distutils.dir_util.copy_tree(LOCAL_DIR, CLOUD_DIR, preserve_mode=0)

def setup_vim(r):
    #make_dpath(r, r.d.VIMFILES)
    # MKLINK /D "%VIMFILES%" "%PORT_SETTINGS%\vim\vimfiles"
    #create_link(r, source=r.d.PORT_SETTINGS+'/vim/vimfiles', target=r.d.VIMFILES)

def pref_windows(r):
    setup_vim(r)
    robos.pref_registry(r)
    robos.no_login_dialog()
    call('attrib +h *.pyc /s')

def pref_settings(r, dry_run = False):
    import distutils.dir_util
    print " *  Setting up Settings"
    
    for (LOCAL_DIR, CLOUD_DIR) in r.symlink_local_cloud:
        print "    *  Symlinking "+LOCAL_DIR+" to "+CLOUD_DIR
        if dry_run:
            LOCAL_DIR = None
        create_link(r, CLOUD_DIR, LOCAL_DIR)

    for (LOCAL_DIR, CLOUD_DIR) in r.directcopy_local_cloud:
        print "    *  Hard Copying Folders: "+CLOUD_DIR+" to "+LOCAL_DIR
        if dry_run:
            LOCAL_DIR = '.'
        distutils.dir_util.copy_tree(CLOUD_DIR, LOCAL_DIR, preserve_mode=1)


def setup(r):
    #pref_registry(r)
    #pref_env(r)
    #pref_shortcuts(r)
    #pref_no_login(r)
    #pref_shortcuts(r)
    #fix_path(r)
