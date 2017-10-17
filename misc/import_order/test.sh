python -c "import decoupled_pkg"

python -c "import decoupled_pkg.mod1"
python -c "from decoupled_pkg import mod1"

python -c "import decoupled_pkg.sub1.mod2"
python -c "from decoupled_pkg.sub1 import mod2"


python -c "import coupled_rel_pkg"
python -c "from coupled_rel_pkg import mod1"

python -c "import coupled_rel_pkg.sub1.mod2"
python -c "from coupled_rel_pkg.sub1 import mod2"
