r"""
Requirements:
    pip install PyGithub

Note:
    a lot of orgs will block the access token unless it expires within 365
    days. I guess we build a new one each year ¯\_(ツ)_/¯

load_secrets
"""

# Authentication is defined via github.Auth
from github import Github
from github import Auth
import os
import ubelt as ub

from datetime import datetime
from rich.markup import escape
from datetime import timedelta
from datetime import UTC
import networkx as nx
import rich


delta = timedelta(days=365 * 20)
now = datetime.now(tz=UTC)
time_threshold = now - delta
# datetime(year=2024, month=1, day=1, tzinfo=UTC)

# using an access token
auth = Auth.Token(os.environ.get('EROTEMIC_GITHUB_RO_TOKEN2'))

# First create a Github instance:

# Public Web Github
g = Github(auth=auth)

# Github Enterprise with custom hostname
# g = Github(base_url="https://{hostname}/api/v3", auth=auth)

# Then play with your Github objects:
user = g.get_user()

# events = user.get_events()
# e = next(iter(events))

user_repos = []
for repo in user.get_repos():
    user_repos.append(repo)
    print(repo.name)


username = user.login

open_issues = []
open_issues_iter = g.search_issues('', state='open', author=username, type='pr', sort='created', order='desc')
for issue in ub.ProgIter(open_issues_iter, desc='Query Open Issues', verbose=3):
    if issue.created_at < time_threshold:
        break
    print(f'issue={issue}, {issue.created_at=}')
    print(issue.repository.name)
    open_issues.append(issue)

closed_issues = []
closed_issues_iter = g.search_issues('', state='closed', author=username, type='pr', sort='created', order='desc')
for issue in ub.ProgIter(closed_issues_iter, desc='Query Closed Issues', verbose=3):
    if issue.created_at < time_threshold:
        break
    print(f'issue={issue}, {issue.created_at=}')
    print(issue.repository.name)
    closed_issues.append(issue)


graph = nx.DiGraph()

issues = closed_issues + open_issues
for issue in issues:
    status = None
    if issue.state == 'open':
        status = 'OPEN'
        color = 'green'
    elif issue.state == 'closed':
        if issue.pull_request.merged_at:
            status = 'MERGED'
            color = 'purple'
        else:
            status = 'CLOSED'
            color = 'red'
    # label = f'[{color}] [link={issue.pull_request.html_url}]#{issue.number} - {escape(issue.title)}[/link] - {escape(issue.created_at.isoformat())}'.replace('\n', '!!!')
    title = issue.title.strip().replace('\n', ' ')
    label = f'[{color}] #{issue.number} - {status} - {escape(title)} - {escape(issue.created_at.date().isoformat())} - [link={issue.pull_request.html_url}]{escape(issue.pull_request.html_url)}[/link]'
    assert '\n' not in label

    graph.add_node(issue.url, label=label)

    graph.add_node(issue.repository.full_name)
    graph.add_node(issue.repository.owner.login)

    graph.add_edge(issue.repository.full_name, issue.url)
    graph.add_edge(issue.repository.owner.login, issue.repository.full_name)

nx.write_network_text(graph, path=rich.print, end='')
