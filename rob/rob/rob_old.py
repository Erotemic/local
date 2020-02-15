# flake8:noqa

def batch_move(r, search, repl, force=False):
    r"""
    This function has not yet been successfully implemented.
    Its a start though.

    rob batch_move train_patchmetric\(.*\) patchmatch\1 False
    ut.named_field('rest', '.*' )
    ut.backref_field('rest')

    search = 'train_patchmetric(?P<rest>.*)'
    repl = 'patchmatch\\g<rest>'
    """
    force = rutil.cast(force, bool)
    # rob batch_move '\(*\)util.py' 'util_\1.py'
    print('Batch Move')
    print('force = %r' % force)
    print('search = %r' % search)
    print('repl = %r' % repl)
    dpath_list = [os.getcwd()]
    spec_open = ['\\(', '\(']
    spec_close = ['\\)', '\)']
    special_repl_strs = ['\1', '\\1']
    print('special_repl_strs = %r' % special_repl_strs)
    print('special_search_strs = %r' % ((spec_open, spec_close,),))

    search_pat = ut.extend_regex(search)
    #for spec in spec_open + spec_close:
    #    search_pat = search_pat.replace(spec, '')
    print('search_pat=%r' % search_pat)

    include_patterns = [search_pat]

    import utool as ut
    import re
    fpath_list = ut.ls('.')
    matching_fpaths = [fpath for fpath in fpath_list if re.search(search_pat, basename(fpath))]
    repl_fpaths = [re.sub(search_pat, repl, fpath) for fpath in matching_fpaths]

    ut.rrrr()
    for fpath1, fpath2 in zip(matching_fpaths, repl_fpaths):
        ut.util_path.copy(fpath1, fpath2, deeplink=False, dryrun=False)
    #for fpath in rob_nav._matching_fnames(dpath_list, include_patterns, recursive=False):
    #    print(fpath)
    return

    parse_str = search
    for spec in spec_open:
        parse_str = parse_str.replace(spec, '{')
    for spec in spec_close:
        parse_str = parse_str.replace(spec, '}')
    parse_str = parse_str.replace('{*}', '{}')
    print('parse_str = %r' % parse_str)

    for fpath in rob_nav._matching_fnames(dpath_list, include_patterns, recursive=False):
        dpath, fname = split(fpath)
        name, ext = splitext(fname)
        # Hard coded parsing
        parsed = parse.parse(parse_str, fname)
        repl1 = parsed[0]
        #print(fname)
        newfname = 'util_' + repl1 + ext
        newfpath = join(dpath, newfname)
        print('move')
        print(fpath)
        print(newfpath)
        if force is True:
            shutil.move(fpath, newfpath)
            print('real run')
        else:
            print('dry run')
        pass


def texinit(r):
    print('Initializing latex directory')

    cralldef_fname    = join(r.d.PORT_LATEX, 'CrallDef.tex')
    crallpreamb_fname = join(r.d.PORT_LATEX, 'CrallPreamb.tex')
    template_fname    = join(r.d.PORT_LATEX, 'template.tex')
    latexmain_fname   = join(r.d.PORT_LATEX, 'template.tex.latexmain')

    #symlink(r, source=r.d.PORT_LATEX, target)
    shutil.copy(cralldef_fname,    './CrallDef.tex')
    shutil.copy(crallpreamb_fname, './CrallPreamb.tex')
    shutil.copy(template_fname,  'main.tex')
    shutil.copy(latexmain_fname, 'main.tex.latexmain')


def fix_sid(r, keep_ext=None):
    search  = 'sID(cm56x3p;)'
    replace = 'sID(5062,cm56x3p;)'
    fname_list = os.listdir(os.getcwd())
    for fname in fname_list:
        if os.path.isfile(fname):
            fname2 = fname.replace(search, replace)
            if fname != fname2:
                print('renaming: %s to %s' % (fname, fname2))
                #os.rename(fname, fname2)


def print_module_funcs(r):
    print('print_module_funcs')
    dpath_list = [os.getcwd()]
    include_patterns = ['*.py']

    def get_function_names(text, prefix='def '):
        preflen = len(prefix)
        line_list = text.split('\n')
        func_lines = [line for line in line_list if line.find(prefix) == 0]
        func_lines = [line[preflen:line.find('(')] for line in func_lines]
        return func_lines

    print('dpath_list = %r' % (dpath_list,))
    print('include_patterns = %r' % (include_patterns,))

    for fpath in rob_nav._matching_fnames(dpath_list, include_patterns, recursive=False):
        modname = splitext(split(fpath)[1])[0]
        with open(fpath) as file_:
            text = file_.read()
            func_list = get_function_names(text, 'def ')
            class_list = get_function_names(text, 'class ')
            modclass_str = ', \n  '.join(func_list + class_list)
            importstr = 'from .' + modname + ' import (' + modclass_str + ')'
            print(importstr)
            print('')
