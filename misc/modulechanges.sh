# hscom
rob sed "import __common__" "from hscom import __common__" True
rob sed "import tools" "from hscom import tools" True
rob sed "from Preferences import Pref" "from hscom.Preferences import Pref" True
rob sed "import latex_formater as pytex" "from hscom import latex_formater as pytex" True
    


rob sed "import fileio as io" "from hscom import fileio as io" True
rob sed "import helpers" "from hscom import helpers" True
rob sed "from Printable import DynStruct" "from hscom.Printable import DynStruct" True
rob sed "from Parallelize import parallel_compute" "from hscom.Parallelize import parallel_compute" True

# hsgui


# hotspotter
rob sed "import HotSpotterAPI" "from hotspotter import HotSpotterAPI" True


# hsviz
rob sed "import vizualizations as viz" "from hsviz import viz" True
rob sed "import draw_func2 as df2" "from hsviz import draw_func2 as df2" True
rob sed "import interaction" "from hsviz import interact" True


rob sed "^from hscom import helpers$" "from hscom import helpers\nfrom hscom import helpers as util" True True

set realrun=True
rob sed "\\bqdat\\b" "qreq" %realrun% True

rob sed "\\bQueryData\\b" "QueryRequest" %realrun% True


from hotspotter import DataStructures as ds
import hotspotter.DatStruct as ds


# Make the mapping from old incorrect names to new correct ones 
# for keypoint shapes

export realrun=False

rob sp '\<_as\>' "_iv11s" $realrun
rob sp '\<_bs\>' "_iv12s" $realrun
rob sp '\<_cs\>' "_iv21s" $realrun
rob sp '\<_ds\>' "_iv22s" $realrun

rob sp '\<acd\>\(' "get_iVs(" $realrun

rob sp '\<scaled_acds\>\(' "scale_iVs(" $realrun
rob sp '\<scaled_xys\>\(' "scale_xys(" $realrun

rob sp '\<get_aff_list\>\(' "get_iV_aff2Ds(" $realrun

rob sp '\<aff_list_noori\>' "iV_aff2Ds" $realrun
rob sp '\<aff_list\>' "iVR_aff2Ds" $realrun


export realrun=False

rob sp '\<iV' 'invV' True
rob sp '_iV' '_invV' True


rob sp '_acds\>' '_invVs' True

rob sp '\<acd' 'ltri' False
rob sp '_acd\>' '_ltri' True
rob sp '\<det_acd\>' 'det_ltri'
rob sp '\<inv_ltri\>' 'det_ltri'

rob sp '\<from hotspotter\>' 'from hsapi' True
rob sp '\<_as\>' "_iv11s"
rob sp '\<_bs\>' "_iv12s"
rob sp '\<_cs\>' "_iv21s"
rob sp '\<_ds\>' "_iv22s"

rob gp '\<acd\('

git mv hscom/params.py hsdev/params.py
git mv hscom/argparse2.py hsdev/argparse2.py

set realrun=True
rob sed "from hscom import params" "from hsdev import params" %realrun% True
rob sed "from hscom import argparse2" "from hsdev import argparse2" %realrun% True


git mv hscom/helpers.py hscom/util.py
rob sed "import helpers as util" "import util" False True
rob sed "\\bhelpers\\b" util False True


cd _graveyard
7z a oldhotspotter.zip oldhotspotter



git mv hsdev/dev_api.py hsdev/dev_augmenter.py
rob sed dev_api dev_augmenter True True


git mv hsdev/test_api.py hsdev/main_api.py
rob sed test_api main_api True True




rob sed "from hsdev import params" "from ibeis.dev import params"

rob sed "from hscom import utool" "import utool"

rob sed "from hsapi" "from ibeis.model.jon_recognition"

rob sed "from hscom import fileio as io" ""


rob sed "from hscom import tools" ""

rob sed "profile, rrr" "rrr, profile" True


rob sed "ibs.gid2_cids" "ibs.get_cids_in_gids"



rob sed "from __future__ import division, print_function" "from __future__ import absolute_import, division, print_function" True True

rob sed "from __future__ import print_function, division" "from __future__ import absolute_import, division, print_function" True True



rob sed "jon_recognition" "hots" True True
git mv ibeis/model/jon_recognition/ ibeis/model/hots


rob sp "drawtool" "plottool"


rob sp ibeis.view ibeis


git mv ~/code/ibeis/ibeis/control/IBEIS_SCHEMA.py ~/code/ibeis/ibeis/control/DB_SCHEMA.py


rob sp get_roi_relationship_ids get_roi_alrids

rob sp get_roi_filtered_relationship_ids get_roi_filtered_alrids

rob sp get_relationship_labelids get_alr_labelids

rob sp get_encounter_eids get_encounter_eids_from_text


rob sp roidist bboxdist

rob sp roi annotion

rob sp ROI ANNOTATION

rob sp _rid _aid

rob sp qrid qaid

rob sp drid daid

rob sp gtrid gtaid

rob sp \\brid aid

rob sp rid aid


ib
rob sedr LABEL ANNOTLABEL True
rob sedr label annotlabel True
rob sp annotlabel propannot
rob sp ANNOTLABEL PROPANNOT 

rob sedr annotlabel annotlbl
rob sedr ANNOTLABEL ANNOTLBL 


rob sedr annotlblid annotlbl_rowid
rob sedr annotlblid annotlbl_rowid

rob sedr set_annotation_from_key set_annotlbl_values_from_aid True

rob sedr key_rowid annotkey_rowid False

rob sedr KEY_TABLE LBLTYPE_TABLE True
rob sedr key_rowid lbltype_rowid True
rob sedr key_table lbltype_table True
rob sedr key_default lbltype_default True
rob sedr key_text lbltype_text True

rob sp set_annotation set_annot True
rob sp get_annotation get_annot True
rob sp delete_annotation delete_annot True
rob sp add_annotation add_annot True


rob sp aif reviewed
revieweds reviewed

rob sp set_annot_from_value set_annot_relationship_from_value
rob sp set_annot_from_value set_annot_label_from_value
rob sp set_annot_from_value set_annot_lblannot_from_value
rob sp set_annot_from_lblannot_rowid set_annot_lblannot_from_rowid


rob sp "\'--no-assert\' in sys.argv or \'--noassert\' in sys.argv" "not (\'--no-assert\' in sys.argv)" 

rob sp get_rowid_from_uuid get_rowid_from_superkey True

#:%s/\(^  *\)\(id_iter = .* in \)\([a-z_]*\))/\1#\2\3)\r\1id_iter = \3/

rob sp get_annot_lblannot_rowids get_annot_lblannot_rowids_oftype


git mv ibeis\model\hots\QueryResult.py ibeis\model\hots\hots_query_result.py
git mv ibeis\model\hots\QueryRequest.py ibeis\model\hots\hots_query_request.py

ib

git mv ibeis/dev/ibsfuncs.py ibeis/ibsfuncs.py
rob sp "from ibeis\\.dev import ibsfuncs" "from ibeis import ibsfuncs" 
rob sp "ibeis\\.dev\\.ibsfuncs" "ibeis.ibsfuncs"
rob sp "ibeis/dev/ibsfuncs" "ibeis/ibsfuncs"


git mv ibeis/dev/all_imports.py ibeis/all_imports.py
rob sp "from ibeis\\.dev import all_imports" "from ibeis import all_imports" 
rob sp "ibeis\\.dev\\.all_imports" "ibeis.all_imports"
rob sp "ibeis/dev/all_imports" "ibeis/all_imports"


git mv ibeis/dev/params.py ibeis/params.py
rob sp "from ibeis\\.dev import params" "from ibeis import params" 
rob sp "from \\. import params" "from ibeis import params" 
rob sp "ibeis\\.dev\\.params" "ibeis.params"
rob sp "ibeis/dev/params" "ibeis/params"


git mv smk.py ibeis/model/hots
git mv smk_core.py ibeis/model/hots
git mv smk_index.py ibeis/model/hots
git mv smk_debug.py ibeis/model/hots

rob sp "from smk" "from ibeis.model.hots.smk"
rob sp "import smk" "from ibeis.model.hots import smk"

rob sp "ibeis.model.hots.smk" "ibeis.model.hots.smk.smk"
rob sp "from ibeis.model.hots import pandas_helpers" "from ibeis.model.hots.smk import pandas_helpers" 

rob sp "ibeis.model.hots.hstypes" "ibeis.model.hots.smk.hstypes"

rob sp "ibeis.model.hots import smk_" "ibeis.model.hots.smk import smk_"
 
rob sp "ibeis.model.hots.pandas_helpers" "ibeis.model.hots.smk.pandas_helpers"

rob gp "[^.]\<get_flag\>"
rob sp "\<get_arg\>" "get_argval" True
rob sp "\<get_flag\>" "get_argflag" True


smk
rob sed "tf" "scc_norm" 
rob sed "scc_norm" "sccw" 


rob sp "mystats" "get_stats"
rob sp "common_stats" "get_stats_str"
rob sp "common_stats" "get_stats_str"
rob sp "\<stats_str\>" "get_stats_str"
rob sp "\<print_get_stats\>" "print_stats"
rob gp "\<print_stats\>"
rob sp "\<print_stats\>" "print_stats"

python -c "import utool; utool.print_auto_docstr('ibeis.model.hots.smk.smk_index', 'compute_negentropy_names')"
python -c "import utool; utool.print_auto_docstr('ibeis.model.hots.nn_weights', 'nn_normalized_weight')"
python -c "import utool; utool.print_auto_docstr('ibeis.model.hots.match_chips4', 'execute_query_and_save_L1')"
python -c "import utool; utool.print_auto_docstr('ibeis.model.hots.pipeline', 'weight_neighbors')" --verbose
python -c "import utool; utool.print_auto_docstr('ibeis.model.hots.pipeline', 'weight_neighbors')" --verbose
python -c "import utool; utool.print_auto_docstr('ibeis.model.hots.pipeline', 'filter_neighbors')" 
python -c "import utool; utool.print_auto_docstr('ibeis.model.hots.pipeline', 'spatial_verification')" 
python -c "import utool; utool.print_auto_docstr('ibeis.model.hots.pipeline', 'precompute_topx2_dlen_sqrd')" 
python -c "import utool; utool.print_auto_docstr('ibeis.model.hots.pipeline', 'chipmatch_to_resdict')" 
python -c "import utool; utool.print_auto_docstr('ibeis.model.hots.pipeline', 'try_load_resdict')" 
python -c "import utool; utool.print_auto_docstr('ibeis.model.hots.pipeline', 'save_resdict')" 
python -c "import utool; utool.print_auto_docstr('ibeis.model.hots.pipeline', 'score_chipmatch')" 
python -c "import utool; utool.print_auto_docstr('ibeis.model.hots.nn_weights', 'apply_normweight')" 
python -c "import utool; utool.print_auto_docstr('ibeis.model.hots.nn_weights', 'get_name_normalizers')" 
python -c "import utool; utool.print_auto_docstr('ibeis.model.hots.nn_weights', 'mark_name_valid_normalizers')" 

python -c "import utool; utool.print_auto_docstr('utool.util_dbg', 'search_stack_for_localvar')" 
python -c "import utool; utool.print_auto_docstr('utool.util_dbg', 'get_parent_locals')" 
python -c "import utool; utool.print_auto_docstr('utool.util_dbg', 'printex')" --verbose
python -c "import utool; utool.print_auto_docstr('utool.util_dbg', 'get_varname_from_locals')" --verbose
python -c "import utool; utool.print_auto_docstr('ibeis.dev.experiment_helpers', 'get_cfg_list_and_lbls')" --verbose



rob sp smk_index.index_data_annots smk_repr.index_data_annots
rob sp smk_index.compute_data_internals_ smk_repr.compute_data_internals_
rob sp smk_index.make_annot_df smk_repr.make_annot_df
rob sp smk_index.new_qindex smk_repr.new_qindex
rob sp smk_core.sccw_summation smk_scoreing.sccw_summation


rob sp classmember make_class_method_decorator
rob sp decorate_make_class_method_decorator decorate_class_method
rob sp classpostinject make_class_postinject_decorator
rob sp decorate_postinject decorate_postinject

git mv io dbio
rob sp "ibeis\.io" "ibeis.dbio"
rob sp "ibeis/io" "ibeis/dbio"

rob sp get_annot_chipsizes get_annot_chip_sizes True
rob sp get_annot_chip_dlen_sqrd get_annot_chip_dlensqrd True
rob sp get_chip_paths get_chip_uris

rob sp "get_annot_chip_fpaths\>" get_annot_chip_fpath True
rob sp "get_annot_probchip_fpaths\>" get_annot_probchip_fpath True

rob sp "from ibeis.dev import experiment_helpers" "from ibeis.experiments import experiment_helpers" True
rob sp "ibeis.dev.experiment_helpers" "ibeis.experiments.experiment_helpers" True

rob sp "from ibeis.dev import experiment_configs" "from ibeis.experiments import experiment_configs" True
rob sp "ibeis.dev.experiment_configs" "ibeis.experiments.experiment_configs" True

rob sp "from ibeis.dev import experiment_harness" "from ibeis.experiments import experiment_harness" True
rob sp "ibeis.dev.experiment_harness" "ibeis.experiments.experiment_harness" True

rob sp "from ibeis.dev import experiment_configs" "from ibeis.experiments import experiment_configs" True
rob sp "ibeis.dev.experiment_configs" "ibeis.experiments.experiment_configs" True

rob sp "from ibeis.dev import experiment_helpers" "from ibeis.experiments import experiment_helpers" True
rob sp "ibeis.dev.experiment_helpers" "ibeis.experiments.experiment_helpers" True

rob sp "from ibeis.dev import results_analyzer" "from ibeis.experiments import results_analyzer" True
rob sp "ibeis.dev.results_analyzer" "ibeis.experiments.results_analyzer" True

rob sp "from ibeis.dev import experiment_harness" "from ibeis.experiments import experiment_harness" True
rob sp "ibeis.dev.experiment_harness" "ibeis.experiments.experiment_harness" True

rob sp "from ibeis.dev import experiment_printres" "from ibeis.experiments import experiment_printres" True
rob sp "ibeis.dev.experiment_printres" "ibeis.experiments.experiment_printres" True

rob sp "from ibeis.dev import results_all" "from ibeis.experiments import results_all" True
rob sp "ibeis.dev.results_all" "ibeis.experiments.results_all" True

rob sp "from ibeis.dev import results_organizer" "from ibeis.experiments import results_organizer" True
rob sp "ibeis.dev.results_organizer" "ibeis.experiments.results_organizer" True

# ---

rob sp "from ibeis.dev import main_commands" "from ibeis.init import main_commands" True
rob sp "ibeis.dev.main_commands" "ibeis.init.main_commands" True

rob sp "from ibeis.dev import main_helpers" "from ibeis.init import main_helpers" True
rob sp "ibeis.dev.main_helpers" "ibeis.init.main_helpers" True

rob sp "from ibeis.dev import sysres" "from ibeis.init import sysres" True
rob sp "ibeis.dev.sysres" "ibeis.init.sysres" True



rob sp "from ibeis.dev import " "from ibeis.init import " True
rob sp "ibeis.dev." "ibeis.init." True

rob sp "from ibeis.dev import " "from ibeis.init import " True
rob sp "ibeis.dev." "ibeis.init." True

ls

modname_list = 'experiment_configs experiment_helpers results_analyzer experiment_harness experiment_printres results_all results_organizer'.split(' ')
modparent_src = 'ibeis.dev'
modparent_dst = 'ibeis.experiments'

modname_list = ut.remove_doublspaces('main_commands.py  main_helpers.py  sysres.py').replace('.py', '').split(' ')
modparent_src = 'ibeis.dev'
modparent_dst = 'ibeis.init'

modname_list = ut.remove_doublspaces('dbinfo.py  duct_tape.py  optimize_k.py').replace('.py', '').split(' ')
modparent_src = 'ibeis.init'
modparent_dst = 'ibeis.dev'

for modname in modname_list:
    cmd_fmtstr = ut.codeblock('''
    rob sp "from {modparent_src} import {modname}" "from {modparent_dst} import {modname}" True
    rob sp "{modparent_src}.{modname}" "{modparent_dst}.{modname}" True
    ''')
    cmd_str = cmd_fmtstr.format(modparent_src=modparent_src, modparent_dst=modparent_dst, modname=modname)
    print(cmd_str)
    print()





rob sp "import cPickle as pickle" "from six.moves import cPickle as pickle" True

rob gp "ibeis\.dev"
rob gp "ibeis\.other" 
rob sp "ibeis\.dev" "ibeis.other" True

rob gp "ibeis .* dev"

git mv chapter2-section1-features.tex chapter2-section1-featdetect.tex
git mv chapter2-section2-neighbors.tex chapter2-section2-neighbors.tex


git mv chapter2-section3-ir.tex chapter2-section4-ir.tex
git mv chapter2-section4-cr.tex chapter2-section5-cr.tex
git mv chapter2-section5-fgr.tex chapter2-section6-fgr.tex
git mv chapter2-section6-dcnn.tex chapter2-section7-dcnn.tex 


git mv chapter2-section3* body-chapter2


rob sp cond_phrase conj_phrase


# new ibeis names

ibeis_ia

dre - detection recognition engine

am - algorithm manager 

dream

amdre

cv - computer vision

ip - image processing

idam - identification detection algorithm manager

osdre  - open source detection recognition engine
ospre  - open source pixel recognition engine

odram - open detection recognition algorithm manager

iam - image analysis module

ibsiam - ibeis - image analysis module

ibiam - ibeis - imabe based image analysis module

ibam - image based analys module
ibam - image based algorithm manager

ibsam -  image based software analysis module

ibsdre -  image based software algorithm manager

iamdre - image algorithm manager detection recognition engine

u  - understanding 
r  - recognition 
m  - manager / module 
i  - image
d  - detection
cv - computer vision
b  - based 
s  - software / server
o  - open / online
p  - pattern
py - python
a  - automated / algorithm / analysis
al - algorithm 
f - functional

alm

amoose

vamoose 
vamuose 

Vision
Algorithm
Manager 
#for
#Online 
Using
Open  
Source 
Engine

VAMOSS

Vision Algorithm Manager Open Source Software

Vision Algorithm Manager Made for Open Source Software


iamodre 

ibam - image based algorithm manager

pybird - Python Based Image Recognition and Detection
pybirde - Python Based Image Recognition and Detection Engine

eagle

animg

am 

pylant

animal

iamve

osvam
pyvam

vamps

veipam

iam

pybeis - python based image systam

iambird - image algorithm manager based instance recognition and detection


rob sp "ut\\.filter_items" "ut.list_compress" True
rob sp "ut\\.ifilter_items" "ut.iter_compress" True
rob sp "ut\\.filter_items" "ut.list_compress" True


grep -ER --include \*.py  model * | grep -v ibeis.model | grep model

grep -ER --include \*.py  model * | grep -v ibeis.model | grep -v statsmodels | grep model 
grep -ER --include \*.py  model * | grep -v ibeis.model | grep -v statsmodels | grep -v bayes | grep model 

rob sp "ibeis\\.model" "ibeis.algo" True
rob gp "ibeis\\.model"

rob sp "ibeis\/model" "ibeis/algo"
rob gp "ibeis.model" 


rob sp "ChipMatch2" "ChipMatch" True


rob sp "ut\.list_take" "ut.take" 
rob sp "ut\.list_compress" "ut.compress" 


rob gp "occurrence"
rob sp "ENCOUNTER" "IMAGESET" True
rob sp "encounter" "imageset" True
rob sp "Encounter" "ImageSet" True
rob sp '(?<![a-zA-Z])encounter' "imageset" True
rob sp '(?<![a-zA-Z])ENCOUNTER' "IMAGESET" True
rob sp '(?<![a-zA-Z])EG_RELATION' "GSG_RELATION" True
rob sp '(?<![a-zA-Z])egr(?![a-zA-Z])' "gsgr" True
rob sp '(?<![a-zA-Z])egrid(?![a-zA-Z])' "gsgrid" True
rob sp '(?<![a-zA-Z])egrids(?![a-zA-Z])' "gsgrids" True
rob sp '(?<![a-zA-Z])eid(?![a-zA-Z])' "imgsetid" True
rob sp '(?<![a-zA-Z])eids(?![a-zA-Z])' "imgsetids" True
True
rob gp "Encounter"

git checkout ibeis/control/DB_SCHEMA.py

rob sp "Encounter" "ImageSet"


# Special cases
ibeis/dbio/export_wb.py
/home/joncrall/code/ibeis/ibeis/algo/preproc/preproc_encounter.py
/home/joncrall/code/ibeis/ibeis/control/manual_wildbook_funcs.py
/home/joncrall/code/ibeis/ibeis/dbio/export_wb.py
/home/joncrall/code/ibeis/ibeis/scripts/getshark.py


# Rename files
~/code/ibeis/ibeis/control/manual_egrelate_funcs.py
~/code/ibeis/ibeis/control/manual_encounter_funcs.py
~/code/ibeis/ibeis/algo/preproc/preproc_encounter.py

git mv manual_encounter_funcs.py manual_imageset_funcs.py
git mv manual_egrelate_funcs.py manual_gsgrelate_funcs.py

rob sp min_imgs_per_imageset min_imgs_per_occurrence
rob sp compute_imagesets compute_occurrences
rob sp enctext imagesettext True
rob sp ENCTEXT IMAGESETTEXT True
rob sp ImageSetConfig OccurrenceConfig

rob sp enc_cfg occur_cfg
rob sp enc_tabwgt imageset_tabwgt True
rob sp _change_enc _change_imageset True
rob sp _add_enc_tab _add_imageset_tab True
rob sp _on_enctab_change _on_imagesettab_change True
rob sp _update_enc_tab_name _update_imageset_tab_name True
rob sp enc_config_rowid_list imageset_config_rowid_list True
rob sp enc_suffix_list imageset_suffix_list True
rob sp ENCTAB IMAGESETTAB True

rob sp INTRA_ENC_KEY INTRA_OCCUR_KEY
rob sp intra_imageset intra_occurrence
rob sp _ADD_ENC_TAB _ADD_IMAGESET_TAB True

rob sp EncTableModel ImagesetTableModel True
rob sp EncTableView ImagesetTableView True
rob sp EncTableWidget ImagesetTableWidget True
rob sp EncoutnerTabWidget ImagesetTabWidget True

rob gp '(?<![a-zA-Z])enc(?![a-zA-Z])'  
rob gp '\c(?<![a-zA-Z])enc(?![a-zA-Z])'  


echo <<EOF
def update_1_5_0(db, ibs=None):
    # Rename encounters to imagesets
    db.rename_table('encounters', 'imagesets')
    db.rename_table('encounter_image_relationship', 'imageset_image_relationship')
    db.modify_table(
        'imagesets', [
            ('encounter_rowid',             'imageset_rowid',              'INTEGER PRIMARY KEY', None),
            ('encounter_uuid',              'imageset_uuid',               'UUID NOT NULL', None),
            ('encounter_text',              'imageset_text',               'TEXT NOT NULL', None),
            ('encounter_note',              'imageset_note',               'TEXT NOT NULL', None),
            ('encounter_start_time_posix',  'imageset_start_time_posix',   'INTEGER', None),
            ('encounter_end_time_posix',    'imageset_end_time_posix',     'INTEGER', None),
            ('encounter_gps_lat',           'imageset_gps_lat',            'INTEGER', None),
            ('encounter_gps_lon',           'imageset_gps_lon',            'INTEGER', None),
            ('encounter_processed_flag',    'imageset_processed_flag',     'INTEGER DEFAULT 0', None),
            ('encounter_shipped_flag',      'imageset_shipped_flag',       'INTEGER DEFAULT 0', None),
            ('encounter_smart_xml_fname',   'imageset_smart_xml_fname',    'TEXT', None),
            ('encounter_smart_waypoint_id', 'imageset_smart_waypoint_id',  'INTEGER', None),
        ],
        docstr='''
        List of all imagesets. This used to be called the encounter table.
        It represents a group of potentially many individuals seen in a
        specific place at a specific time.
        ''',
        superkeys=[('imageset_text',)],
    )
    db.modify_table(
        'imageset_image_relationship', [
            ('egr_rowid',       'gsgr_rowid',      'INTEGER PRIMARY KEY', None),
            ('encounter_rowid', 'imageset_rowid',  'INTEGER', None),
        ],
        docstr='''
        Relationship between imagesets and images (many to many mapping) the
        many-to-many relationship between images and imagesets is encoded
        here imageset_image_relationship stands for imageset-image-pairs.
        ''',
        superkeys=[('image_rowid', 'imageset_rowid')],
        relates=('images', 'imagesets'),
        shortname='gsgr',
        dependsmap={
            'imageset_rowid': ('imagesets', ('imageset_rowid',), ('imageset_text',)),
            'image_rowid'    : ('images', ('image_rowid',), ('image_uuid',)),
        },
    )
    #pass
EOF


# Try and remove these
rob gp "print, print_, printDBG, rrr, profile = "
rob gp " *print_\\("


# TODO Change testdata to demodata?
rob sp testdata demodata


rob sp ibeis.algo.hots.graph_iden ibeis.algo.graph_iden.core
rob sp ibeis.algo.hots.sim_graph_iden ibeis.algo.graph_iden.sim_graph_iden
rob sp ibeis.algo.hots.demo ibeis.algo.graph_iden.demo
from ibeis.algo.hots import graph
rob sp "from ibeis.algo.hots import graph" "from ibeis.algo.graph_iden import graph"
rob sp "graph_iden_depmixin" "dep_mixins"
rob sp "sim_graph_iden" "simulate"
rob sp "dep_mixins" "_dep_mixins"
rob sp "graph_iden_new" "core2"
rob sp "demo_graph_iden" "demo"
rob sp "graph_iden_mixins" "mixin_helpers"
rob sp "graph_iden_utils" "nx_utils"
rob sp "dyngraph" "nx_dynamic_graph"
rob sp "demo_graph_iden" "demo"



rob sp "infr.queue_params\\['pos_redun'\\]" "infr.params['redun.pos']" True
rob sp "infr.queue_params\\['neg_redun'\\]" "infr.params['redun.neg']" True

rob sp "infr.enable_auto_prioritize_nonpos" "infr.params['autoreview.prioritize_nonpos']" True
rob sp "infr.enable_attr_update" "infr.params['inference.update_attrs']" True
rob sp "infr.enable_autoreview" "infr.params['autoreview.enabled']" True
rob sp "infr.enable_fixredun" "infr.params['redun.enforce_pos']" True
rob sp "infr.enable_inference" "infr.params['inference.enabled']" True
rob sp "infr.enable_redundancy" "infr.params['redun.enabled']" True

rob sp "infr.classifiers" "infr.verifiers" True


rob sedr "^from pysseg.torch import" "from . import"
rob sedr "^from pysseg\." "from ."

cd ~/code/clab/clab
rob sedr pysseg clab True

cgrep ">>> .*sys.path"
cgrep ">>> .*sys.path"

rob sedr "^from clab\.torch import" "from . import"
rob sedr "^from clab\." "from ." True
rob sedr "^    from clab\." "    from ." True
rob sedr "^        from clab\." "        from ." True
rob sedr "^from clab import" "from . import" True

cd ~/code/clab/clab/live
rob sed "clab.torch.urban_train" "clab.live.urban_train"  True
rob sed "clab.torch.siam_train" "clab.live.siam_train"  True
rob sed "clab.torch.sseg_train" "clab.live.sseg_train"  True
rob sed "clab.torch.urban_mapper" "clab.live.urban_mapper"  True


rob sedr "^from \. import" "from clab import" True
rob sedr "^from \." "from clab." 


import plottool as pt
from clab import mplutil
