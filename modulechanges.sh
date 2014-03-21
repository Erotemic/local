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
