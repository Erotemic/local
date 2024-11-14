local
=====

Jon Crall's dotfiles repo (before he knew dotfiles was a standard name), might change in the future.


Initialize
==========

.. code:: bash

    # Install git if necessary
    if ! command -v "$COMMAND" &> /dev/null; then
        sudo apt install git -y
    fi
    # Navigate to the home folder
    cd ~
    # Clone the repo
    git clone https://github.com/Erotemic/local.git

    # If credentials are setup
    # bash ~/local/init.sh

    # Customize settings (if unset they will try to choose sensible defaults)
    # export HAVE_SUDO=False
    export IS_HEADLESS=True
    export WITH_SSH_KEYS=False
    source ~/local/init.sh

    # export HAVE_SUDO=True
    # export IS_HEADLESS=False
    # export WITH_SSH_KEYS=False
    # source ~/local/init.sh

About Me
========

Badges / shields for my projects:

|xdoctest| |ubelt| |mkinit| |vimtk| |xdev| |progiter| |timerit| |git-sync| |line_profiler| |ibeis| |graphid| |hotspotter| |crall-thesis-2017| |pypogo| |shitspotter|


.. |xdoctest| image:: https://img.shields.io/github/stars/Erotemic/xdoctest?style=social&label=stars:xdoctest
    :target: https://github.com/Erotemic/xdoctest
.. |ubelt| image:: https://img.shields.io/github/stars/Erotemic/ubelt?style=social&label=stars:ubelt
    :target: https://github.com/Erotemic/ubelt
.. |mkinit| image:: https://img.shields.io/github/stars/Erotemic/mkinit?style=social&label=stars:mkinit
    :target: https://github.com/Erotemic/mkinit
.. |vimtk| image:: https://img.shields.io/github/stars/Erotemic/vimtk?style=social&label=stars:vimtk
    :target: https://github.com/Erotemic/vimtk
.. |xdev| image:: https://img.shields.io/github/stars/Erotemic/xdev?style=social&label=stars:xdev
    :target: https://github.com/Erotemic/xdev
.. |progiter| image:: https://img.shields.io/github/stars/Erotemic/progiter?style=social&label=stars:progiter
    :target: https://github.com/Erotemic/progiter
.. |timerit| image:: https://img.shields.io/github/stars/Erotemic/timerit?style=social&label=stars:timerit
    :target: https://github.com/Erotemic/timerit
.. |git-sync| image:: https://img.shields.io/github/stars/Erotemic/git-sync?style=social&label=stars:git-sync
    :target: https://github.com/Erotemic/git-sync
.. |line_profiler| image:: https://img.shields.io/github/stars/Erotemic/line_profiler?style=social&label=stars:line_profiler
    :target: https://github.com/Erotemic/line_profiler


.. |ibeis| image:: https://img.shields.io/github/stars/Erotemic/ibeis?style=social&label=stars:ibeis
    :target: https://github.com/Erotemic/ibeis
.. |graphid| image:: https://img.shields.io/github/stars/Erotemic/graphid?style=social&label=stars:graphid
    :target: https://github.com/Erotemic/graphid
.. |hotspotter| image:: https://img.shields.io/github/stars/Erotemic/hotspotter?style=social&label=stars:hotspotter
    :target: https://github.com/Erotemic/hotspotter
.. |crall-thesis-2017| image:: https://img.shields.io/github/stars/Erotemic/crall-thesis-2017?style=social&label=stars:crall-thesis-2017
    :target: https://github.com/Erotemic/crall-thesis-2017


.. |pypogo| image:: https://img.shields.io/github/stars/Erotemic/pypogo?style=social&label=stars:pypogo
    :target: https://github.com/Erotemic/pypogo
.. |shitspotter| image:: https://img.shields.io/github/stars/Erotemic/shitspotter?style=social&label=stars:shitspotter
    :target: https://github.com/Erotemic/shitspotter


* https://gitlab.kitware.com.com/python/liberator
* https://gitlab.kitware.com.com/utils/scriptconfig
* https://gitlab.kitware.com.com/computer-vision/torch_liberator

* https://gitlab.kitware.com.com/computer-vision/kwcoco
* https://gitlab.kitware.com.com/computer-vision/kwarray
* https://gitlab.kitware.com.com/computer-vision/kwimage
* https://gitlab.kitware.com.com/computer-vision/kwplot

* https://gitlab.kitware.com.com/computer-vision/netharn
* https://gitlab.kitware.com.com/computer-vision/ndsampler



.. .. See ~/local/misc/badges.py for autogen

Contributions to External Repos
-------------------------------


TODO: find a way to script this


Link to see closed PRs
https://github.com/pulls?q=is%3Apr+author%3AErotemic+archived%3Afalse+is%3Aclosed

* https://github.com/HadrienG/taxadb/commits?author=Erotemic
* https://github.com/Kitware/SMQTK/commits?author=Erotemic
* https://github.com/Kitware/fletch/commits?author=Erotemic
* https://github.com/Kitware/kwiver/commits?author=Erotemic
* https://github.com/KitwareMedical/AnatomicRecon-POCUS-AI/commits?author=Erotemic
* https://github.com/Lasagne/Lasagne/commits?author=Erotemic
* https://github.com/LuminosoInsight/ordered-set/commits?author=Erotemic
* https://github.com/OSGeo/gdal/commits?author=Erotemic
* https://github.com/OpenDebates/openskill.py/commits?author=Erotemic
* https://github.com/Project-MONAI/MONAI/commits?author=Erotemic
* https://github.com/ResonantGeoData/ResonantGeoData/commits?author=Erotemic
* https://github.com/TeamHG-Memex/tensorboard_logger/commits?author=Erotemic
* https://github.com/Theano/Theano/commits?author=Erotemic
* https://github.com/VIAME/VIAME/commits?author=Erotemic
* https://github.com/alan-turing-institute/distinctipy/commits?author=Erotemic
* https://github.com/aleju/imgaug/commits?author=Erotemic
* https://github.com/apache/airflow/commits?author=Erotemic
* https://github.com/djentleman/imgrender/commits?author=Erotemic
* https://github.com/elasticdog/transcrypt/commits?author=Erotemic
* https://github.com/facebookarchive/caffe2/commits?author=Erotemic
* https://github.com/fmfn/BayesianOptimization/commits?author=Erotemic
* https://github.com/harlowja/fasteners/commits?author=Erotemic
* https://github.com/iterative/dvc.org/commits?author=Erotemic
* https://github.com/iterative/dvc/commits?author=Erotemic
* https://github.com/lark-parser/lark/commits?author=Erotemic
* https://github.com/lucidrains/performer-pytorch/commits?author=Erotemic
* https://github.com/mahmoud/boltons/commits?author=Erotemic
* https://github.com/msbanik/drawtree/commits?author=Erotemic
* https://github.com/networkx/networkx/commits?author=Erotemic
* https://github.com/open-mmlab/mmdetection/commits?author=Erotemic
* https://github.com/opencv/opencv/commits?author=Erotemic
* https://github.com/opengm/opengm/commits?author=Erotemic
* https://github.com/pandas-dev/pandas/commits?author=Erotemic
* https://github.com/pgmpy/pgmpy/commits?author=Erotemic
* https://github.com/pypa/cibuildwheel/commits?author=Erotemic
* https://github.com/pytorch/pytorch/commits?author=Erotemic
* https://github.com/pytorch/vision/commits?author=Erotemic
* https://github.com/qutip/qutip/commits?author=Erotemic
* https://github.com/rspeer/ordered-set/commits?author=Erotemic
* https://github.com/scikit-build/scikit-build/commits?author=Erotemic
* https://github.com/scikit-image/scikit-image/commits?author=Erotemic
* https://github.com/scikit-learn/scikit-learn/commits?author=Erotemic
* https://github.com/sciunto-org/python-bibtexparser/commits?author=Erotemic
* https://github.com/sylhare/nprime/commits?author=Erotemic
* https://github.com/ultrajson/ultrajson/commits?author=Erotemic
* https://github.com/vascobnunes/fetchLandsatSentinelFromGoogleCloud/commits?author=Erotemic
* https://github.com/wimglenn/johnnydep/commits?author=Erotemic
* https://github.com/yaml/pyyaml/commits?author=Erotemic
