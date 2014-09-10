import os
from os.path import join, split, expanduser, exists
HOME = expanduser('~')
srcdir = join(HOME, 'Dropbox/Code')
os.chdir(srcdir)

import pymol
import urllib
import molecule_info as mols
#http://www.pymolwiki.org/index.php/Label
#CmdLoad: "C:/Users/joncrall/Downloads/caffeine.pdb" loaded as "caffeine".


def ball_and_stick():
    pymol.preset.ball_and_stick(selection='all', mode=1)
    pymol.cmd.set('valence', 'on')
    pymol.cmd.set('stick_ball_ratio', '1')
    pymol.cmd.set('stick_radius', 0.1)
    pymol.cmd.set('sphere_scale', 0.2)
    pymol.cmd.set('orthoscopic', 1)


def simple():
    pymol.preset.ligand_cartoon()
    pymol.preset.simple()


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


def download_molecule(molecule, overwrite=True):
    href = molecule.href
    fname = split(href)[1]
    fpath = join(os.getcwd(), fname)
    if not overwrite and exists(fpath):
        return fpath
    download_text(href, fpath)
    return fpath


def display(molecule):
    fpath = download_molecule(molecule, overwrite=False)
    pymol.api.delete('all')
    pymol.api.load(fpath)
    ball_and_stick()

# Launch pymol
pymol.finish_launching()

# Define molecule names from molecule_info
oxytocin    = mols.oxytocin
caffeine    = mols.caffeine
atp         = mols.ATP
adenosine   = mols.adenosine
epinephrine = mols.epinephrine
ibuprofen   = mols.ibuprofen

# Display a molecule
display(ibuprofen)
