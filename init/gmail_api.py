

import httplib2
import os

from apiclient import discovery
from oauth2client import client
from oauth2client import tools
from oauth2client.file import Storage

from os.path import expanduser

try:
    import argparse
    flags = argparse.ArgumentParser(parents=[tools.argparser]).parse_args()
except ImportError:
    flags = None

PROJECT_NAME = 'JonCrallEmailPreferences'

# If modifying these scopes, delete your previously saved credentials
# at ~/.credentials/gmail-python-quickstart.json
# SCOPES = 'https://www.googleapis.com/auth/gmail.readonly'

# Add other requested scopes.
SCOPES = [
    'https://www.googleapis.com/auth/gmail.readonly',
    'https://www.googleapis.com/auth/userinfo.email',
    'https://www.googleapis.com/auth/userinfo.profile',
    'https://www.googleapis.com/auth/gmail.settings.basic',
]

CLIENT_SECRET_FILE = expanduser('~/Dropbox/secrets/gmail_oath.json')
APPLICATION_NAME = 'Gmail API Python Quickstart'


def get_credentials():
    """Gets valid user credentials from storage.

    If nothing has been stored, or if the stored credentials are invalid,
    the OAuth2 flow is completed to obtain the new credentials.

    Returns:
        Credentials, the obtained credential.
    """
    home_dir = os.path.expanduser('~')
    credential_dir = os.path.join(home_dir, '.credentials')
    if not os.path.exists(credential_dir):
        os.makedirs(credential_dir)
    credential_path = os.path.join(credential_dir,
                                   'gmail-python-quickstart.json')

    store = Storage(credential_path)
    credentials = store.get()
    if not credentials or credentials.invalid:
        flow = client.flow_from_clientsecrets(CLIENT_SECRET_FILE, SCOPES)
        flow.user_agent = APPLICATION_NAME
        if flags:
            credentials = tools.run_flow(flow, store, flags)
        else:
            credentials = tools.run(flow, store)
        print('Storing credentials to ' + credential_path)
    return credentials


def main():
    """Shows basic usage of the Gmail API.

    Creates a Gmail API service object and outputs a list of label names
    of the user's Gmail account.

    References:
        https://developers.google.com/gmail/api/guides/filter_settings

    Example:
        >>> import sys
        >>> sys.path.append('/home/joncrall/local/init')
        >>> from gmail_api import *
    """
    credentials = get_credentials()
    http = credentials.authorize(httplib2.Http())
    service = discovery.build('gmail', 'v1', http=http)

    my_labels = {
        'Dashboards'                : 'Label_1',
        'Kitware-L2-Vision'         : 'Label_6',
        'Kitware-L3-Invites'        : 'Label_4',
        'Kitware-L4-Complete'       : 'Label_2',
        'Kitware-L5-All'            : 'Label_5',
        'Kitware-L9-sick-late-home' : 'Label_7'
    }

    wfh_parts = [
        'WFH', 'Working from home', 'Out today', 'Out of the office',
        'Running late this',
    ]

    my_filters = dict(
        wfh={
            'action': {
                'addLabelIds': ['Label_7'],
                'removeLabelIds': ['UNREAD'],
            },
            'criteria': {
                'subject': ' OR '.join(["{}".format(p) for p in wfh_parts]),
            },
        },
        vision={
            'action': {
                'addLabelIds': ['Label_6'],
                'removeLabelIds': ['INBOX'],
            },
            'criteria': {
                'query': 'list:"vision@kitware.com" has:nouserlabels',
            },
        }
    )

    users_api = service.users()
    threads_api = users_api.threads()
    labels_api = users_api.labels()
    settings_api = users_api.settings()
    filter_api = settings_api.filters()

    wfh_threads = threads_api.list(userId='me', labelIds=['Label_7']).execute()
    import ubelt as ub
    class MyThread(ub.NiceRepr):
        def __init__(self, data):
            self.subject = None
            self.data = data
            self.meta = None

        def __nice__(self):
            return self.subject

        def load_meta(self):
            meta = threads_api.get(userId='me', format='metadata',
                                   metadataHeaders=['Subject'],
                                   id=self.data['id']).execute()
            self.meta = meta

        def load_attrs(self):
            headers = self.meta['messages'][0]['payload']['headers']
            for h in headers:
                if h['name'].lower() == 'subject':
                    self.subject = h['value']

    mythreads = []
    for data in wfh_threads['threads']:
        self = MyThread(data)
        mythreads.append(self)

    for self in ub.ProgIter(mythreads):
        self.load_meta()

    for self in ub.ProgIter(mythreads):
        self.load_attrs()

    for self in mythreads:
        print(self.subject)
        print(self.data['snippet'])

    import re
    needs_fix = [s for s in mythreads if not re.search(ut.regex_or(wfh_parts), s.subject, flags=re.IGNORECASE)]

    filters_json = filter_api.list(userId='me').execute()
    print(ut.repr3(filters_json, nl=4))

    labels_json = service.users().labels().list(userId='me').execute()
    labels = labels_json.get('labels', [])
    {l['name']: l['id'] for l in labels if l['type'] == 'user'}

    if not labels:
        print('No labels found.')
    else:
        print('Labels:')
        for label in labels:
            print(label['name'])


if __name__ == '__main__':
    main()
