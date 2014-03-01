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
