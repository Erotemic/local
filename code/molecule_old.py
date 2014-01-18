import pymol
import os
import urllib
from os.path import join, split, expanduser, exists

HOME = expanduser('~')
srcdir = join(HOME, 'Dropbox/Code')
os.chdir(srcdir)


def write_text(text, fpath):
    print('writing to: %r' % fpath)
    with open(fpath, 'w') as file_:
        file_.write(text)


def download_text(href, dest=None):
    print('downloading from: %r' % href)
    sock = urllib.urlopen(href)
    text = sock.read()
    sock.close()
    if dest is not None:
        write_text(text, dest)
    else:
        return text


def download_molecule(molid='caffeine', overwrite=True, ideal=True):
    ''' http://www.pdb.org/pdb/home/home.do
        http://midas3.kitware.com/midas/item/34769
    '''
    midas3 = r'http://midas3.kitware.com/midas/download/bitstream/153455/'
    rcsb = r'http://www.rcsb.org/pdb/files/ligand/'
    if ideal:
        pdbechem = r'ftp://ftp.ebi.ac.uk/pub/databases/msd/pdbechem/files/pdb/'
    else:  # representative
        pdbechem = r'ftp://ftp.ebi.ac.uk/pub/databases/msd/pdbechem/files/pdb_r/'

    # Download root
    # dynamic hard codings
    href_dict = {
        'caffeine':  midas3 + 'caffeine.pdb',
        'atp':       rcsb + 'ATP_ideal.sdf',
        'adenosine': pdbechem + 'ADN.pdb',
        'oxytocin': 'http://www.rcsb.org/pdb/files/1NPO.pdb',
        'epinephrine': 'http://www.drugbank.ca/drugs/DB00668.sdf',

    }
    href = href_dict[molid] if molid in href_dict else molid
    fname = split(href)[1]
    fpath = join(os.getcwd(), fname)
    if not overwrite and exists(fpath):
        return fpath
    download_text(href, fpath)
    return fpath


def grab(molid):
    return download_molecule(molid, overwrite=False)


pymol.finish_launching()


pymol.api.delete('all')
#pymol.api.load(grab('caffeine'))
#pymol.api.load(grab('atp'))
#pymol.api.load(grab('adenosine'))
pymol.api.load(grab('oxytocin'))
#pymol.api.load(grab('epinephrine'))


def ball_and_stick():
    pymol.preset.ball_and_stick(selection='all', mode=1)
    pymol.cmd.set('valence', 'on')
    pymol.cmd.set('stick_ball_ratio', '1')
    pymol.cmd.set('stick_radius', 0.1)
    pymol.cmd.set('sphere_scale', 0.2)
    pymol.cmd.set('orthoscopic', 1)

    commands = '''
    preset.ball_and_stick(selection='all', mode=2)
    show sticks
    set valence, on
    set stick_ball, on
    set stick_ball_ratio, 1
    set stick_radius, 0.0012
    set orthoscopic=1
    '''
    print(commands)


def simple():
    pymol.preset.ligand_cartoon()
    pymol.preset.simple()

ball_and_stick()
simple()
#http://www.pymolwiki.org/index.php/Label
#CmdLoad: "C:/Users/joncrall/Downloads/caffeine.pdb" loaded as "caffeine".
