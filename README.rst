local
=====

Badges / shields for all of my projects:


.. code ::

    https://img.shields.io/badge/dynamic/json?url=<URL>&label=<LABEL>&query=<$.DATA.SUBDATA>&color=<COLOR>&prefix=<PREFIX>&suffix=<SUFFIX>

    https://img.shields.io/pypi/dm/ubelt.svg

    https://img.shields.io/github/stars/Erotemic/ubelt?style=for-the-badge

    .. image:: https://img.shields.io/github/stars/Erotemic/ubelt?style=for-the-badge   :alt: GitHub Repo stars

    https://img.shields.io/static/v1/lael=<LABEL>
    github/stars/Erotemic/ubelt?style=for-the-badge   :alt: GitHub Repo stars

    https://img.shields.io/static/v1/lael=<LABEL> ?label=healthinesses
    ?link=https://github.com/Erotemic/ubelt

    &query=<$.DATA.SUBDATA>&

    <//data/subdata>


    https://img.shields.io/badge/dynamic/yaml?url=https://github.com/Erotemic/ubelt&prefix=thisisaprefix&suffix=thisissuf

    	/github/downloads/:user/:repo/:tag/total
    
    &label=This_is_a_label
    &query=github/stars/Erotemic/ubelt
    &prefix=thisisaprefix
    &suffix=thisissuf
    https://img.shields.io/badge/dynamic/yaml?url=https://github.com/Erotemic/ubelt&label=This_is_a_label&query=github/stars/Erotemic/ubelt&prefix=thisisaprefix&suffix=thisissuf
    color=<COLOR>

    

    ![GitHub User's stars](
    https://img.shields.io/github/stars/Erotemic?style=social
    )



?color=orange

?style=for-the-badge&logo=appveyor


https://img.shields.io/badge/dynamic/json?url=https://github.com/Erotemic/ubelt&label=<LABEL>&query=<$.DATA.SUBDATA>&color=blue&prefix=<PREFIX>&suffix=<SUFFIX>



https://img.shields.io/github/followers/Erotemic.svg?style=social&label=Followers:Erotemic&maxAge=2592000

https://img.shields.io/github/stars/Erotemic/ubelt?style=social&label=stars:ubelt

https://img.shields.io/github/followers/Erotemic.svg?style=social&label=Followers:Erotemic&maxAge=2592000

)](https://github.com/Naereen?tab=followers)


[![GitHub stars](https://img.shields.io/github/stars/Naereen/StrapDown.js.svg?style=social&label=Star&maxAge=2592000)](https://GitHub.com/Naereen/StrapDown.js/stargazers/)



https://img.shields.io/github/stars/Erotemic/xdoctest?style=social&label=stars:xdoctest
https://img.shields.io/github/stars/Erotemic/ubelt?style=social&label=stars:ubelt

git_repos = """

xdoctest
ubelt
mkinit
vimtk
xdev
progiter
timerit
git-sync
line_profiler


ibeis
graphid
hotspotter
crall-thesis-2017


pypogo
shitspotter

""".split('\n')

f'|{repo_name}|' for repo_name in git_repos:


for repo_name in git_repos:
    if not repo_name.strip():
        print('')
    else:
        print(f'''
        .. |{repo_name}| image:: https://img.shields.io/github/stars/Erotemic/{repo_name}?style=social&label=stars:{repo_name}
            :target: https://github.com/Erotemic/{repo_name}
     ''')
