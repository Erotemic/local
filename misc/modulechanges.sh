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

:%s/\(^  *\)\(id_iter = .* in \)\([a-z_]*\))/\1#\2\3)\r\1id_iter = \3/

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
