def rrr():
    import imp
    import sys
    file_ = vars().get('__file__', 'molecule_info')
    imp.reload(sys.modules[file_])

#----------------------
# Classes of molecules
#----------------------


class GLYCOSYLAMINE(object):
    properties = 'amine with beta-nitorogen glycosidic bond to a carbohyrdate'


class PEPTIDE(object):
    properties = 'changes of amino acid monomers linked by peptide (amine) bonds'


class STEROID(object):
    properties = 'caracteristic arangement of four cycloalkane rings that are joined to each other'


class EICOSANOID(object):
    properties = 'complex signaling molecules made by oxidation of 20-carbon fatty acids'


class ACHIRAL(object):
    properties = 'symmetric'


class CHIRAL(object):
    properties = 'asymmetric'


class XANTHINE(ACHIRAL):
    properties = ['stimulant']


class CATECHOLAMINE(object):
    properties = 'derived from the amino acid tyrosine'


class AMINE(object):
    properties = 'nitogren based. derived from amonia'


class phenethylamine(AMINE):
    pass


#----------------------
# Specific of molecules
#----------------------

class amphetamine(object):
    pass


class dextroamphetamine(object):
    pass


class ibuprofen(object):
    href = 'Ligands_noHydrogens_noMissing_9_Instances.sdf'
    effects = ['antiplatelet', 'vasodilatation']
    inhibits = ['enzyme cyclooxygenase (COX)']


class caffeine(XANTHINE):
    href = 'http://midas3.kitware.com/midas/download/bitstream/153455/caffeine.pdb'
    antagonizes = ['adenosine']
    inhibits = ['fine motor control', 'fatigue', 'cardiovascular disease', 'diabetes']
    increases = ['vasoconstriction', 'blood pressure', 'anxiety', 'metabolism',
                 'alertness', 'attention', 'urination']


class adenosine_triphosphate(GLYCOSYLAMINE):
    isa   = 'nucleoside triphosphate'
    href  = 'http://www.rcsb.org/pdb/files/ligand/ATP_ideal.sdf'
    feels = ['energy']
ATP = adenosine_triphosphate


class adenosine(GLYCOSYLAMINE):
    href  = 'ftp://ftp.ebi.ac.uk/pub/databases/msd/pdbechem/files/pdb_r/ADN.pdb'
    href2 = 'ftp://ftp.ebi.ac.uk/pub/databases/msd/pdbechem/files/pdb_r/'
    feels = ['tired']
ADN = adenosine


class oxytocin(PEPTIDE):
    href     = r'http://www.rcsb.org/pdb/files/1NPO.pdb'
    feels    = ['bonding', 'trust', 'romance']
    inhibits = ['anxiety']
OXT = oxytocin


class prolactin(PEPTIDE):
    pass

#-------------
# ESTROGENS


class estradiol(STEROID):
    chemical_class = 'estrogen'
    notes          = 'metabolite of testosterone. Most potent of the estrogens'
    feels          = ['libido', 'lordosis']
    increases      = ['cortisol']
    inhibits       = ['bone reabsorbtion', 'sperm apoptosis']
    supports       = ['platelet adhesiveness', 'bone formation', 'metabolism', 'Coagulation', 'protein syntesis']
    grows          = ['height', 'endometrium', 'uterus']
    maintains      = ['blood vessels', 'skin', 'alveoli']
    shrinks        = ['muscle mass']
E2 = estradiol


class estriol(STEROID):
    chemical_class = 'estrogen'
E3 = estriol


class estrone(STEROID):
    chemical_class = 'estrogen'
E1, oestrone = [estrone] * 2
#-------------


class cortisol(STEROID):
    chemical_class = 'glucocorticoid'
    feels     = ['stress']
    supports  = ['flash memory formation', 'fat breakdown', 'glucose uptake']
    decreases = ['bone formation']
    supresses  = ['long term memory', 'immune responce']
    involved  = ['appetite', 'obesity']
hydrocortisone = cortisol


class cortisone(STEROID):
    # NOT ON THE LIST
    feels = ['anxiety', 'fight of flight']
    supresses = ['immune system']
    notes = 'much more active thatn cortisol'
_17hydroxy_11dehydrocorticosterone = cortisone


class progesterone(STEROID):
    chemical_class = 'progestogen'
    href        = r'http://www.drugbank.ca/drugs/DB00668.sdf'
    inhibits    = ['stress', 'spasms']
    involved    = ['apoptosis']
    antagonizes = ['cortisol']
    involved    = ['apoptosis']


class testosterone(STEROID):
    feels    = ['arousal', 'attention']
    supports = ['spatial ability (quadratic relationship)', 'memory'
                'antisocial behavior', 'alchoholism']
    grows    = ['bone density', 'muscle mass']


class tyrosine(CATECHOLAMINE):
    notes = 'one of the 22 amino acids'
tyr, _y = [tyrosine] * 2


class l_tyrosine(CATECHOLAMINE):
    isomer_of = tyrosine  # same chemical forumla different structure


class tryptophan():
    notes = 'one of the 22 amino acids'


class l_tryptophan():
    isomer_of = tryptophan

#--------------------
# Norepinephrine System


class l_dopa(CATECHOLAMINE):
    derived_from = l_tyrosine


class dopamine(CATECHOLAMINE):
    derived_from = l_dopa
    feels = ['cognitive alertness', 'hunger', 'attentive', 'clarity',
             'modivated']
    supports = ['working memory']
    deficit_feels = ['memory fatigued', 'compulsive', 'foggy']


class norepinephrine(CATECHOLAMINE):
    #http://en.wikipedia.org/wiki/Norepinephrine
    #http://en.wikipedia.org/wiki/File:NorepinephrineDopamineSerotonin.png
    derived_from = dopamine
    notes = 'syntesized from dopamine'
    feels = ['vigilant concentration', 'intuitive', 'attentive', 'percerverant']
    deficit_feels = ['execution fatigue', 'hesitant', 'obsessive', 'impaired memory recall']
    increases = ['heart rate', 'brain oxygen supply']
noradrenaline = norepinephrine


class epinephrine(CATECHOLAMINE):
    href = r'http://www.drugbank.ca/drugs/DB00668.sdf'
    derived_from = norepinephrine
    enhances = ['long term memory']
    involved = ['memory consolidation']
adrenaline, adrenalin = [epinephrine] * 2


class serotonin():
    derived_from = l_tryptophan
    feels = ['learning fatigue', 'satisfaction', 'intuitive', 'appetite', 'relaxed']
    deficit_feels = ['confused', 'anxious', 'restless']
    enhances = ['submissive behavior']
    inhibits = ['the need to flee']


class melatonin():
    derived_from = serotonin
    notes = 'powerful antioxidant'
    protects = 'nuclear and mitocondrial DNA'
    feels = ['sleepy']
    involved_in = ['memory']
