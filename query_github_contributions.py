"""
pip install PyGithub

load_secrets
export GIT_RO_TOKEN=$(git_token_for github_ro)
"""

# Authentication is defined via github.Auth
from github import Github
from github import Auth
import os
import ubelt as ub

# using an access token
auth = Auth.Token(os.environ.get('GIT_RO_TOKEN'))

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
open_issues = g.search_issues('', state='open', author=username, type='pr')

closed_issues_iter = g.search_issues('', state='closed', author=username, type='pr')
closed_issues = []
for issue in ub.ProgIter(closed_issues_iter):
    print(f'issue={issue}')
    print(issue.repository.name)
    closed_issues.append(issue)


parent = repo.parent
list(parent.get_pulls())


repo.get_pulls


for repo in user_repos:
    if repo.name == 'networkx':
        break
    ...

pulls = repo.get_pulls(state='all', sort='created', base='master')

for pr in pulls:
    print(pr.number)

