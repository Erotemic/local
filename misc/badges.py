import ubelt as ub
from textwrap import dedent


# # Autogen
# git_repos = """

# xdoctest
# ubelt
# mkinit
# vimtk
# xdev
# progiter
# timerit
# git-sync
# line_profiler


# ibeis
# graphid
# hotspotter
# crall-thesis-2017


# pypogo
# shitspotter

# """.split('\n')


# lines = []
# for repo_name in git_repos:
#     if repo_name.strip():
#         lines.append(f'|{repo_name}|')
# print(' '.join(lines))


# for repo_name in git_repos:
#     if not repo_name.strip():
#         print('')
#     else:
#         print(dedent(
#             f'''
#              .. |{repo_name}| image:: https://img.shields.io/github/stars/Erotemic/{repo_name}?style=social&label=stars:{repo_name}
#                  :target: https://github.com/Erotemic/{repo_name}
#              ''').strip())


github_repos = """

xdoctest
ubelt
mkinit
vimtk
xdev
progiter
timerit
git-sync
pyutils/line_profiler


ibeis
graphid
hotspotter
crall-thesis-2017


pypogo
shitspotter

""".split('\n')

print(' '.join([f'|{repo_suffix}|' for repo_suffix in github_repos if repo_suffix.strip()]))
for repo_suffix in github_repos:
    repo_suffix = repo_suffix.strip()
    if not repo_suffix.strip():
        print('')
    else:
        if '/' in repo_suffix:
            user_name, repo_name = repo_suffix.split('/')
        else:
            user_name = 'Erotemic'
            repo_name = repo_suffix

        sheild_url = f'https://img.shields.io/github/stars/{user_name}/{repo_name}?style=social&label=stars:{repo_name}'
        link_url = f'https://github.com/{user_name}/{repo_name}'

        md_link = f'[![GitHub stars]({sheild_url})]({link_url})'
        print(md_link)

        rst_dclr = ub.codeblock(
            f'''
            .. |{repo_suffix}| image:: {sheild_url}
            :target:
            ''')
        # print(rst_dclr)


gitlab_repos = """
python/liberator
utils/scriptconfig
computer-vision/torch_liberator

computer-vision/kwcoco
computer-vision/kwarray
computer-vision/kwimage
computer-vision/kwplot

computer-vision/netharn
computer-vision/ndsampler

""".split('\n')
# print(' '.join([f'|{repo_suffix}|' for repo_suffix in gitlab_repos if repo_suffix.strip()]))

# print('
for repo_suffix in gitlab_repos:

    repo_suffix = repo_suffix.strip()
    if not repo_suffix.strip():
        print('')
    else:
        if '/' in repo_suffix:
            user_name, repo_name = repo_suffix.split('/')
        else:
            user_name = 'Erotemic'
            repo_name = repo_suffix

        sheild_url = f'https://img.shields.io/gitlab/stars/{user_name}/{repo_name}?style=social&label=stars:{repo_name}'
        link_url = f'https://gitlab.kitware.com.com/{user_name}/{repo_name}'

        print(f'* {link_url}')

        # md_link = f'[![GitLab stars]({sheild_url})]({link_url})'
        # print(md_link)

        rst_dclr = ub.codeblock(
            f'''
            .. |{repo_suffix}| image:: {sheild_url}
            :target:
            ''')
        # print(rst_dclr)


# .. ..  Notes
# .. .. ?color=orange
# .. .. ?style=for-the-badge&logo=appveyor
# .. .. https://img.shields.io/badge/dynamic/json?url=https://github.com/Erotemic/ubelt&label=<LABEL>&query=<$.DATA.SUBDATA>&color=blue&prefix=<PREFIX>&suffix=<SUFFIX>
# .. .. https://img.shields.io/github/followers/Erotemic.svg?style=social&label=Followers:Erotemic&maxAge=2592000
# .. .. https://img.shields.io/github/stars/Erotemic/ubelt?style=social&label=stars:ubelt
# .. .. https://img.shields.io/github/followers/Erotemic.svg?style=social&label=Followers:Erotemic&maxAge=2592000
# .. .. )](https://github.com/Naereen?tab=followers)
# .. .. [![GitHub stars](https://img.shields.io/github/stars/Naereen/StrapDown.js.svg?style=social&label=Star&maxAge=2592000)](https://GitHub.com/Naereen/StrapDown.js/stargazers/)


# See:
# .. code-block::

#     https://img.shields.io/badge/dynamic/json?url=<URL>&label=<LABEL>&query=<$.DATA.SUBDATA>&color=<COLOR>&prefix=<PREFIX>&suffix=<SUFFIX>

#     https://img.shields.io/pypi/dm/ubelt.svg

#     https://img.shields.io/github/stars/Erotemic/ubelt?style=for-the-badge

#     .. image:: https://img.shields.io/github/stars/Erotemic/ubelt?style=for-the-badge   :alt: GitHub Repo stars

#     https://img.shields.io/static/v1/lael=<LABEL>
#     github/stars/Erotemic/ubelt?style=for-the-badge   :alt: GitHub Repo stars

#     https://img.shields.io/static/v1/lael=<LABEL> ?label=healthinesses
#     ?link=https://github.com/Erotemic/ubelt

#     &query=<$.DATA.SUBDATA>&

#     <//data/subdata>


#     https://img.shields.io/badge/dynamic/yaml?url=https://github.com/Erotemic/ubelt&prefix=thisisaprefix&suffix=thisissuf

#         /github/downloads/:user/:repo/:tag/total

#     &label=This_is_a_label
#     &query=github/stars/Erotemic/ubelt
#     &prefix=thisisaprefix
#     &suffix=thisissuf
#     https://img.shields.io/badge/dynamic/yaml?url=https://github.com/Erotemic/ubelt&label=This_is_a_label&query=github/stars/Erotemic/ubelt&prefix=thisisaprefix&suffix=thisissuf
#     color=<COLOR>

#     ![GitHub User's stars](
#     https://img.shields.io/github/stars/Erotemic?style=social
#     )


"""
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
"""
