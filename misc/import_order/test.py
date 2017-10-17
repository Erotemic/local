
print('--- DECOUPLED PKG ---')
python -c "import decoupled_pkg"
python -c "from decoupled_pkg import mod1"


print('--- COUPLED PKG ---')
import coupled_rel_pkg
