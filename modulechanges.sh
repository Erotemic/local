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
