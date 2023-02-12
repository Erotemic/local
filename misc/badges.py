"""
python ~/local/misc/badges.py
"""
import ubelt as ub
from textwrap import dedent
from tabulate import tabulate


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

computer-vision/delayed_image
computer-vision/cmd_queue

watch/watch
""".split('\n')


def github_links():
    ...


def pypkg_links(repo_name, link_url):
    download_sheild_url = f'https://img.shields.io/pypi/dm/{repo_name}.svg'
    pypistats_url = f'https://pypistats.org/packages/{repo_name}'
    pypi_url = f'https://pypi.python.org/pypi/{repo_name}'
    md_downloads = f'[![Downloads]({download_sheild_url})]({pypistats_url})'
    docs_url = f'https://{repo_name}.readthedocs.io/en/latest/'
    rtd_sheild_url = f'https://readthedocs.org/projects/{repo_name}/badge/?version=latest'
    md_docs = f'[![Docs]({rtd_sheild_url})]({docs_url})'
    return locals()


def main():

    nopypi_list = [
        'hotspotter', 'crall-thesis-2017', 'shitspotter',
        'watch/watch',
    ]

    refs = [[f'|gh_sheild_{repo_suffix}|'] for repo_suffix in github_repos if repo_suffix.strip()]
    headers = ['Github']

    tablestr = tabulate(refs, tablefmt='rst', headers=headers)
    print(tablestr)
    # print(' '.join(refs))

    repo_rows = []
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

            main_link_url = f'https://github.com/{user_name}/{repo_name}'
            gh_sheild_url = f'https://img.shields.io/github/stars/{user_name}/{repo_name}?style=social&label=stars:{repo_name}'
            md_githubstars = f'[![GitHub stars]({gh_sheild_url})]({main_link_url})'
            # print(md_link)

            if repo_suffix in nopypi_list:
                pypkg_attrs = {}
            else:
                pypkg_attrs = pypkg_links(repo_name, main_link_url)

            rst_dclr = ub.codeblock(
                f'''
                .. |gh_sheild_{repo_suffix}| image:: {gh_sheild_url}
                :target:
                ''')

            if 'line' in repo_name and 'profiler' in repo_name:
                pypkg_attrs.pop('md_docs')

            md_name = f'[{repo_name}]({main_link_url})'
            repo_rows.append({
                'repo': repo_suffix,
                'repo_name': repo_name,
                'user_name': user_name,
                'md_name': md_name,

                'md_githubstars': md_githubstars,
                **pypkg_attrs,

                'rst_dclr': rst_dclr,
                'main_link_url': main_link_url,
                'gh_sheild_url': gh_sheild_url,
            })
            # print(rst_dclr)

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
            main_link_url = f'https://gitlab.kitware.com/{user_name}/{repo_name}'
            gh_user_name = 'Kitware'
            gh_link_url = f'https://github.com/{gh_user_name}/{repo_name}'
            gh_sheild_url = f'https://img.shields.io/github/stars/{gh_user_name}/{repo_name}?style=social&label=stars:{repo_name}'
            md_githubstars = f'[![GitHub stars]({gh_sheild_url})]({gh_link_url})'

            # print(f'* {main_link_url}')
            # md_link = f'[![GitLab stars]({sheild_url})]({main_link_url})'
            # print(md_link)
            rst_dclr = ub.codeblock(
                f'''
                .. |{repo_suffix}| image:: {sheild_url}
                :target:
                ''')
            # print(rst_dclr)
            if repo_suffix in nopypi_list:
                pypkg_attrs = {}
            else:
                pypkg_attrs = pypkg_links(repo_name, main_link_url)

            md_name = f'[{repo_name}]({main_link_url})'
            repo_rows.append({
                'repo': repo_suffix,
                'repo_name': repo_name,
                'user_name': user_name,
                'md_name': md_name,

                'md_githubstars': md_githubstars,
                **pypkg_attrs,

                'rst_dclr': rst_dclr,
                'main_link_url': main_link_url,
                'sheild_url': sheild_url,
            })

    # print(' '.join([f'|{repo_suffix}|' for repo_suffix in gitlab_repos if repo_suffix.strip()]))
    import pandas as pd
    df = pd.DataFrame(repo_rows)
    # print(df[['repo', 'github_stars', 'downloads']])

    mapping = {
        'md_name': 'Name',
        'md_githubstars': 'Github Stars',
        'md_downloads': 'Pypi Downloads',
        'md_docs': 'Docs',
    }
    subset = df[list(mapping.keys())].set_index('md_name')
    subset = subset.rename(mapping, axis=1)
    tablestr = tabulate(subset.values.tolist(), tablefmt='markdown', headers=subset.columns)
    # print(tablestr)
    print(subset.to_markdown())


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
if __name__ == '__main__':
    """
    CommandLine:
        python ~/local/misc/badges.py
    """
    main()
