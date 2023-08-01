#!/usr/bin/env python3
"""
Python helpers

Vocabulary And Abbreviations
============================

Fingerprint (FPR) - I think this is the safest / most specific way to reference a key?


GPG Syntax Tips
===============

GPG Commands will often accept a USER-ID field, which INDIRECTLY indicates
which key is to be used, or which key is to be targeted. It's important to note
that this is an indirect mechanism, and it should be thought more of as a query
that could return multiple matches.

* The '=' prefix syntax - forces an exact match to a user id
* The '!' suffix syntax - forces an exact match to a fingerprint

Note, GPG does not always respect these rules. See
[KeyQuerySpec]_ for a details.


Useful Native GPG Commands
==========================


# List Packets

Given a GPG compressed GPG message or output format, lists human readable
packets that make up the content of the message [Anatomy]_.


..code::

    gpg --list-packets --verbose

    # Example
    gpg -a --export | gpg --list-packets --verbose
    gpg -a --export-secret-keys | gpg --list-packets --verbose


References
==========
[1]            .. https://illuad.fr/2020/10/06/build-an-openpgp-key-based-on-ecc.html
[2]            .. https://security.stackexchange.com/questions/169538/generate-subkeys-based-on-less-secure-openpgp-primary-key
[3]            .. https://security.stackexchange.com/questions/255358/why-does-ecc-not-have-an-encrypt-capability-in-gpg-but-rsa-does
[Anatomy]      .. https://davesteele.github.io/gpg/2014/09/20/anatomy-of-a-gpg-key/
[KeyQuerySpec] .. https://www.gnupg.org/documentation/manuals/gnupg/Specify-a-User-ID.html
[5]            .. https://gitlab.com/biomedit/gpg-lite/-/issues/28
[6]            .. https://wiki.debian.org/Subkeys
[7]            .. https://github.com/drduh/YubiKey-Guide
[8]            .. https://incenp.org/notes/2015/using-an-offline-gnupg-master-key.html


See Also
========
pip install gpg-lite
python -m pip install git+https://gitlab.com/biomedit/gpg-lite.git

~/misc/learn/send_me_a_gpg_message.sh


Requirements
============

sudo apt install expect -y
pip install fire ubelt

"""
import warnings
import ubelt as ub


DEFAULT_CAPABILITIES = {
    'certify', 'sign', 'encrypt',
}


class _ExpectScript:
    """
    Helps build expect scripts that can be run in bash.

    Example:
        >>> from gpg_tool import _ExpectScript  # NOQA
        >>> script = _ExpectScript('ftp')
        >>> script - '> ftp'
        >>> script < 'quit'
        >>> print(script.finalize())
        >>> print(script.execute())
        >>> #
        >>> script = _ExpectScript('ftp', regex=True)
        >>> script - '> ftp'
        >>> script < 'quit'
        >>> print(script.finalize())
        >>> print(script.execute())
        >>> #
        >>> script = _ExpectScript('ftp')
        >>> script.expect('> ftp')
        >>> script.send('quit')
        >>> print(script.finalize())
        >>> #
        >>> script = _ExpectScript('ftp')
        >>> script.expect('ftp> ').send('help').expect('ftp> ').send('ls').expect('ftp> ').send('quit')
        >>> print(script.finalize())
        >>> script.execute()
    """
    def __init__(self, command, regex=False):
        self.command = command
        self.regex = regex
        self.lines = []

    def __sub__(self, other):
        return self.expect(other)

    def __gt__(self, other):
        return self.expect(other)

    def __lt__(self, other):
        return self.send(other)

    def expect(self, text, regex=None):
        if regex is None:
            regex = self.regex

        if regex:
            text = str(text)
            line = 'expect -re {' + text + '};'
        else:
            text = str(text)
            assert '"' not in text
            assert "'" not in text
            line = 'expect "{}"'.format(text)
        self.lines.append(line)
        return self

    def send(self, text):
        text = str(text)
        assert '"' not in text
        assert "'" not in text
        if self.regex:
            line = r'send -- "{}\r";'.format(text)
        else:
            line = r'send "{}\r";'.format(text)
        self.lines.append(line)
        return self

    def finalize(self):
        script_lines = ["expect -c '"] + ['spawn ' + self.command] + self.lines + ["interact", "'"]
        text = '\n'.join(script_lines)
        return text

    def execute(self):
        import ubelt as ub
        text = self.finalize()
        ub.cmd(text, shell=True, verbose=3)


def _keyalgo_prompt(script, keyalgo, keysize, curve, capabilities):
    """
    A note on capabilities:

        Signing is signing data (i.e. gpg --sign the_file)

        Certification is signing a key (i.e. gpg --sign-key the_key)

        Authentication is signing a challenge (like ssh does).  The
        Authentication stuff can be used to log in to a machine using your GPG
        key.

    References:
        https://lists.gnupg.org/pipermail/gnupg-users/2005-April/025390.html
        https://superuser.com/questions/390265/what-is-a-gpg-with-authenticate-capability-used-for

    """
    if capabilities is None:
        capabilities = {'certify'}
    if isinstance(capabilities, str):
        capabilities = set(capabilities.split(','))

    if keyalgo == 'ECC':
        if capabilities == {'encrypt'}:
            need_choose_capabilities = False
            kind_code = 12
        else:
            need_choose_capabilities = True
            kind_code = 11

    elif keyalgo == 'RSA':
        kind_code = 8
        need_choose_capabilities = True
    else:
        raise Exception

    script - ('Your selection? ')
    script < (kind_code)
    if need_choose_capabilities:
        if keyalgo == 'ECC':
            assert 'encrypt' not in capabilities

        to_remove = DEFAULT_CAPABILITIES - capabilities
        to_add = capabilities - DEFAULT_CAPABILITIES

        # print('capabilities = {!r}'.format(capabilities))
        # print('to_add = {!r}'.format(to_add))
        to_toggle = (to_remove | to_add) - {'certify'}
        # print('to_toggle = {!r}'.format(to_toggle))
        for capability in to_toggle:
            capability_code = capability[0].upper()
            script - ('Your selection? ')
            script < (capability_code)

        # Quit the capability selection
        script - ('Your selection? ')
        script < ('Q')

        # Choose keysize in bits
        if keyalgo == 'RSA':
            if isinstance(keysize, str):
                if keysize == 'max':
                    keysize = 4068
                elif keysize == 'min':
                    keysize = 1024
            script - ('What keysize do you want? (3072)')
            script < (keysize)

    if keyalgo == 'ECC':
        curve = '25519'
        if curve == 'auto':
            curve = '25519'
        curve_code = {
            '25519': 1,
            'Brainpool P-256': 6,
            'Brainpool P-384': 7,
            'Brainpool P-512': 8,
            'secp256k1': 9,
        }[curve]
        script - ('Please select which elliptic curve you want:')
        script < (curve_code)


def _known_entries(identifier=None, verbose=0):
    """
    References:
        # Format of the colon listings
        https://github.com/gpg/gnupg/blob/master/doc/DETAILS
    """
    suffix = ''
    if identifier is not None:
        suffix = ' ' + chr(34) + identifier + chr(34)
    info = ub.cmd('gpg --with-colons --fixed-list-mode --list-keys --keyid-format LONG' + suffix, verbose=verbose)

    default_field_info = {
        1: 'type',         # Field 1 - Type of record
        2: 'valid',        # Field 2 - Validity
        3: 'len',          # Field 3 - Key length
        4: 'pkalgo',       # Field 4 - Public key algorithm
        5: 'keyid',        # Field 5 - KeyID
        6: 'created',      # Field 6 - Creation Date
        7: 'expires',      # Field 7 - Expiration Date
        8: 'cert',
        9: 'ownertrust',
        10: 'uid',          # Field 10 - UserId
        11: 'sigclass',
        12: 'capabilities',
        13: 'issuer',
        14: 'flags',
        15: 'sn',
        16: 'hasher',
        17: 'curve',  }

    special_info = {
        'tru': {1: 'type', 2: 'stale', 3: 'trust', 4: 'date_create'},
        'pkd': {1: 'type', 2: 'index', 3: 'info', 4: 'value'},
        'cfg': {1: 'type'}}

    header = []
    entries = []
    current = None

    valid_lines = [line for line in info['out'].split(chr(10)) if line]
    for line in valid_lines:
        parts = line.split(':')
        rec_type = parts[0]
        if rec_type in special_info:
            field_info = special_info[rec_type]
        else:
            field_info = default_field_info
        record = {}
        for i, val in enumerate(parts, start=1):
            record[field_info.get(i, i)] = val
        if record['type'] == 'pub':
            if current is not None:
                entries.append(current)
            current = []
        if current is None:
            header.append(record)
        else:
            current.append(record)
    if current is not None:
        entries.append(current)
    return entries


def _find_key_index(keyid):
    # Find the key index because apparently edit key does not respect the !
    entries = _known_entries(keyid, verbose=3)
    assert len(entries) == 1, 'ambiguous identity'
    entry = entries[0]
    key_index = -1
    found = None
    for row in entry:
        if row['type'] in {'pub', 'sub'}:
            key_index += 1
            if keyid == row['keyid']:
                found = key_index
                break
        if row['type'] == 'fpr':
            if row['uid'] == keyid:
                found = key_index
                break
    assert found is not None
    return found


class GPGCLI:
    """
    A simple non-interactive command-line interface
    """

    def _create_new_key2():
        """
        Requirements:
            python -m pip install git+https://gitlab.com/biomedit/gpg-lite.git
        """
        # Use gpg_lite
        import gpg_lite
        import tempfile
        tmp = tempfile.TemporaryDirectory()
        gpg_store = gpg_lite.GPGStore(
            gnupg_home_dir=tmp.name
        )
        print('tmp.name = {!r}'.format(tmp.name))
        # Init directory
        _ = ub.cmd('gpg -k', env={'GNUPGHOME': tmp.name}, verbose=3)
        _ = ub.cmd('gpg -k', env={'GNUPGHOME': tmp.name}, verbose=3, check=True)

        primary_fpr = gpg_store.gen_key(
            full_name='Emmy Noether',
            email='emmy.noether@uni-goettingen.de',
            passphrase=None,
            key_type='eddsa',
            subkey_type='ecdh',
            key_curve='Ed25519',
            subkey_curve='Curve25519'
        )

        _ = ub.cmd(f'gpg -k {primary_fpr}', env={'GNUPGHOME': tmp.name}, verbose=3, check=True)
        _ = ub.cmd(f'gpg -k {primary_fpr}', env={'GNUPGHOME': tmp.name}, verbose=3, check=True)

        from gpg_tool import GPGCLI  # NOQA
        GPGCLI.add_subkey(primary_fpr, capabilities={'sign'})

    @staticmethod
    def create_new_key(name, email, comment='', expires=0, keyalgo='ECC',
                       keysize='max', curve='25519', passphrase=None,
                       capabilities=None, dry=False):
        r"""
        Note: running this script will prompt for a password

        Args:
            keyalgo (str): code indicating the type of key (rsa or ecc)
            capabilities (Set[str]):
                capabilities can be sign, encrypt, authenticate, and certify (which is all)

            keyalgo:
                RSA or ECC

            keysize:
                only applicable for RSA

            curve:
                only applicable for ECC

        CommandLine:
            python ~/code/erotemic/safe/gpg_tool.py create_new_key \
                --name "Emmy Noether" --email "emmy.noether@uni-goetingen.de" \
                --keysize=min

        Example:
            >>> from xgpg import *  # NOQA
            >>> name = 'Emmy Noether'
            >>> comment = ''
            >>> email = 'emmy.noether@uni-goettingen.de'
            >>> keyalgo = 'RSA'
            >>> expires = 0
            >>> capabilities = {'authenticate'}
            >>> text = create_new_key(name, email, keysize='min',
            >>>                       capabilities=capabilities, dry=True)
            >>> print(text)
        """
        print('create_new_key: {}'.format(ub.repr2(locals(), sort=0)))

        # Buidl the body of the expect script
        script = _ExpectScript('gpg --full-generate-key --expert --pinentry-mode loopback')

        _keyalgo_prompt(script, keyalgo, keysize, curve, capabilities)

        # Choose keysize in bits
        # expire_time = '1y'
        # expire_time = 0
        script - ('Key is valid for? (0)')
        script < (expires)
        script - ('Is this correct? (y/N) ')
        script < ('y')

        assert len(name) >= 5
        script - ('Real name: ')
        script < (name)

        script - ('Email Address: ')
        script < (email)

        if comment:
            warnings.warn('dont use comments')

        script - ('Comment: ')
        script < ('')

        script - ('Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? '),
        script < ('O')

        if not passphrase:
            script - ('Enter passphrase: ')
            script < ('')
            script < ('')
        else:
            script - ('Enter passphrase: ')
            script < (passphrase)
            # raise NotImplementedError

        # return script
        if dry:
            return script.finalize()
        else:
            script.execute()

    @staticmethod
    def add_subkey(parent_keyid, capabilities=None, keyalgo='ECC',
                   curve='25519', keysize='max', expires='1y', passphrase=None,
                   dry=False):
        """
        Note: running this script will prompt for a password

        Args:
            parent_keyid (str): the parent key id

            passphrase (None | str):
                Note: if the parent key has a passphrase this must match

        Example:
            >>> import sys, ubelt
            >>> sys.path.append(ubelt.expandpath('~/code/erotemic/safe'))
            >>> from gpg_tool import *  # NOQA
            >>> parent_keyid = '9258E7A3'
            >>> capabilities = {'sign'}
            >>> text = add_subkey(parent_keyid, capabilities)
            >>> print(text)
        """
        print('create_new_key: {}'.format(ub.repr2(locals(), sort=0)))
        script = _ExpectScript('gpg --expert --pinentry-mode loopback --edit-key {} '.format(parent_keyid))
        script - ('gpg> ')
        script < ('addkey')

        _keyalgo_prompt(script, keyalgo, keysize, curve, capabilities)

        # Choose keysize in bits
        expires = '1y'
        script - ('Key is valid for? (0)')
        script < (expires)
        script - ('Is this correct? (y/N) ')
        script < ('y')

        script - ('Really create?')
        script < ('y')

        if not passphrase:
            script - ('Enter passphrase: ')
            script < ('')
            script < ('')
        else:
            script - ('Enter passphrase: ')
            script < (passphrase)

        script - ('gpg> ')
        script < ('save')

        if dry:
            return script.finalize()
        else:
            script.execute()

    @staticmethod
    def generate_revoke_certificate(keyid, fpath, dry=False):
        """
        Note:
            This can only be used to revoke a primary key.
            Subkeys cannot only be revoked immediately.
            See :func:`revoke_subkey`

        Refererences:
            https://security.stackexchange.com/questions/94165/do-i-need-to-revoke-both-my-openpgp-primary-key-and-subkey

        """
        s = _ExpectScript(
            'gpg --pinentry-mode loopback --output "{}" --gen-revoke {}! '.format(fpath, keyid),
        )

        s - 'Create a revocation certificate for this key? (y/N) '
        s < 'y'

        s - 'Please select the reason for the revocation:'
        s < '0'

        s - 'Enter an optional description; end it with an empty line:'
        s < ''

        s - 'Is this okay? (y/N)'
        s < 'y'

        if dry:
            return s.finalize()
        else:
            s.execute()

    @staticmethod
    def revoke_subkey(keyid, dry=False):
        keyindex = _find_key_index(keyid)

        s = script = _ExpectScript(
            'gpg --pinentry-mode loopback --edit-key {}! '.format(keyid),
            regex=False
        )
        s - ('gpg> ')
        s < ('key ' + str(keyindex))

        s - ('gpg> ')
        s < 'revkey'

        s - 'Do you really want to revoke this subkey? (y/N) '
        s < 'y'

        s - 'Your decision? '
        s < '0'

        s - 'Enter an optional description; end it with an empty line:'
        s < ''

        s - 'Is this okay? (y/N) '
        s < 'y'

        s - ('gpg> ')
        s < ('quit')

        if dry:
            return script.finalize()
        else:
            script.execute()

    @staticmethod
    def renew_subkey(keyid, extend, dry=False):
        """
        extend = '1y'

        python ~/code/erotemic/safe/gpg_tool.py renew_subkey --keyid=83466B8331F038E054D3BD327466EDAC8816B8C0 --extend=17y
        python ~/code/erotemic/safe/gpg_tool.py renew_subkey --keyid=4EA85E0336D74943541C8F803C957FA10181A006 --extend=1y
        python ~/code/erotemic/safe/gpg_tool.py renew_subkey --keyid=83CC3E5EDD797685C0555F856947220A6E973063 --extend=1y
        """
        keyindex = _find_key_index(keyid)

        s = script = _ExpectScript(
            'gpg --pinentry-mode loopback --edit-key {}! '.format(keyid),
            regex=False
        )
        s - ('gpg> ')
        s < ('key ' + str(keyindex))

        s - ('gpg> ')

        s < ('expire')
        s - ('Key is valid for? (0) ')
        s < (extend)
        s - ('Is this correct? (y/N) ')
        s < ('y')

        # s - 'gpg: You may want to change its expiration date too. *'
        # s < 'key 1'

        # s - ('gpg> *')
        # s < ('expire')
        # s - ('Key is valid for?.*')
        # s < (extend)
        # s - ('Is this correct?.*')
        # s < ('y')

        # new_trust_code = 5
        # s - ('gpg> *')
        # s < ('trust')
        # s - ('Your decision? *')
        # s < new_trust_code
        # s - ('Do you really want to set this key to.*')
        # s < 'y'

        s - ('gpg> ')
        s < ('save')

        if dry:
            return script.finalize()
        else:
            script.execute()

    @staticmethod
    def add_uid(keyid, name, email, dry=False):
        keyindex = _find_key_index(keyid)

        s = script = _ExpectScript(
            'gpg --pinentry-mode loopback --edit-key {}! '.format(keyid),
            regex=False
        )
        s - ('gpg> ')
        s < ('key ' + str(keyindex))

        s - 'gpg> '
        s < 'adduid '

        s - 'Real Name: '
        s < name

        s - 'Email address: '
        s < email

        s - 'Comment: '
        s < ''

        s - 'Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? '
        s < 'O'

        s - 'gpg> '
        s < 'save '

        if dry:
            return script.finalize()
        else:
            script.execute()

    @staticmethod
    def delete_key(keyid):
        """
        Remove the public and private keys for a key pair
        """
        ub.cmd('gpg --delete-secret-keys {}!'.format(keyid), verbose=2)
        ub.cmd('gpg --delete-key {}!'.format(keyid), verbose=2)

    @staticmethod
    def lookup_keyid(identifier, verbose=0, capabilities=None, allow_subkey=True, allow_mainkey=True, full=True):
        """
        python ~/local/scripts/xgpg.py lookup_keyid "Emmy"
        python ~/local/scripts/xgpg.py lookup_keyid "Crall" --allow_mainkey=False --capabilities=sign
        python ~/local/scripts/xgpg.py lookup_keyid "Crall" --allow_mainkey=False --capabilities=encrypt
        python ~/local/scripts/xgpg.py lookup_keyid "Crall" --allow_mainkey=False --capabilities=auth
        python ~/local/scripts/xgpg.py lookup_keyid "Jonathan Crall"
        """
        if capabilities is None:
            capabilities = {'certify'}
        if isinstance(capabilities, str):
            capabilities = set(capabilities.split(','))

        entries = _known_entries(identifier)

        # print(ub.repr2(entries, nl=2, sort=0))
        if verbose:
            import pandas as pd
            # print('entries = {}'.format(ub.repr2(entries, nl=2)))
            for rows in entries:
                rows_df = pd.DataFrame(rows)
                rows_df.index.name = 'row'
                print(rows_df.to_string())
                # print(ub.repr2(entries, nl=2, si=1, sort=0))
        if len(entries) != 1:
            print('entries = {}'.format(ub.repr2(entries, nl=1)))
            raise Exception('Identifier is not unique!')
        else:
            want_caps = {c[0] for c in capabilities}
            candidates = []

            allowed_row_types = set()
            if allow_subkey:
                allowed_row_types.add('sub')
            if allow_mainkey:
                allowed_row_types.add('pub')

            rows = entries[0]
            for idx, row in enumerate(rows):
                if row['type'] in allowed_row_types:
                    have_caps = set(row.get('capabilities', ''))
                    if have_caps.issuperset(want_caps):
                        keyid = row['keyid']
                        if full:
                            # Find the full fingerprint
                            jdx = idx + 1
                            while jdx < len(rows) and rows[jdx]['type'] == 'fpr':
                                fpr = rows[jdx]['uid']
                                if fpr.endswith(keyid):
                                    keyid = fpr
                                jdx += 1
                        candidates.append(keyid)

            if len(candidates) == 0:
                raise Exception('no matches found for this query')
            if len(candidates) > 1:
                print('candidates = {}'.format(ub.repr2(candidates, nl=1)))
                raise Exception('query is ambiguous')
            assert len(candidates) == 1
            keyid = candidates[0]
            return keyid

    @staticmethod
    def lookup_name(keyid):
        info = ub.cmd('gpg --list-keys --keyid-format LONG "{}"'.format(keyid))
        line = info['out'].split('\n')[2]
        name = line[line.find(']') + 2:line.rfind('<') - 1]
        return name

    @staticmethod
    def lookup_email(keyid):
        info = ub.cmd('gpg --list-keys --keyid-format LONG "{}"'.format(keyid))
        line = info['out'].split('\n')[2]
        email = line[line.rfind('<') + 1:-1]
        return email

    @staticmethod
    def edit_trust(keyid, level, dry=False):
        script = _ExpectScript('gpg --expert --pinentry-mode loopback --edit-key {} '.format(keyid))
        script - ('gpg> ')
        script < ('trust')

        script - ('Your decision?')
        level_lut = {'unknown': 1, 'none': 2, 'marginal': 3, 'full': 4, 'ultimate': 5}
        level = str(level_lut.get(level, level))
        script < (level)

        if level == '5':
            script - ('Do you really want to set this key to ultimate trust? (y/N)')
            script < ('y')

        script - ('gpg> ')
        script < ('save')

        if dry:
            return script.finalize()
        else:
            script.execute()

    @staticmethod
    def available_entropy():
        ub.cmd('cat /proc/sys/kernel/random/entropy_avail', shell=True, verbose=2)

    @staticmethod
    def fix_gnupghome_permissions():
        import os
        dpath = os.environ.get('GNUPGHOME', ub.expandpath('$HOME/.gnupg'))
        print('dpath = {!r}'.format(dpath))
        os.makedirs(os.path.join(dpath, 'private-keys-v1.d'), exist_ok=True)
        # 600 for files and 700 for directories
        ub.cmd('find ' + dpath + r' -type f -exec chmod 600 {} \;', shell=True, verbose=2)
        ub.cmd('find ' + dpath + r' -type d -exec chmod 700 {} \;', shell=True, verbose=2)

    @staticmethod
    def sign_file(src, dst=None, sign_keyid=None, dry=False, verbose=1):
        """
        Args:
            src (fpath): path to sign
            dst (fpath): output path, if unspecified writes to stdout.
        """
        parts = [
            'gpg --clearsign --armor'
        ]
        was_temp = False
        if dst is None:
            was_temp = True
            import tempfile
            dst = ub.Path(tempfile.mktemp(suffix='.asc'))
            parts += [f'-o {dst}']

        if sign_keyid is not None:
            parts += [
                f'--local-user {sign_keyid}',
            ]
        parts += [
            f'{src}'
        ]

        command = ' '.join(parts)
        toreturn = []
        if not dry:
            dst = ub.Path(dst)
            if dst.exists():
                dst.delete()
            ub.cmd(command, verbose=3)
            if was_temp:
                print(dst.read_text())
                dst.delete()
            else:
                print(f'wrote to: {dst}')
        else:
            toreturn.append(command)

        return toreturn

    @staticmethod
    def sign_text(text, sign_keyid, verbose=1):
        """
        Signs text that proves its from you.

        Example:
            import sys, ubelt
            sys.path.append(ubelt.expandpath('~/local/scripts'))
            from xgpg import *  # NOQA
            sign_keyid = '4AC8B478335ED6ED667715F3622BE571405441B4'
            text = f'Hello. My public GPG key is: {sign_keyid}'
            GPGCLI.sign_text(text, sign_keyid, verbose=1)
        """
        # Probably not secure
        if verbose:
            print('text = {!r}'.format(text))
        import tempfile
        text_fpath = tempfile.NamedTemporaryFile(mode='w', suffix='.txt')

        if sign_keyid == 'None':
            sign_keyid = None

        if verbose:
            print('text_fpath = {!r}'.format(text_fpath))
            print('text_fpath.name = {!r}'.format(text_fpath.name))

        if sign_keyid is None or sign_keyid == 'None':
            raise AssertionError

        with text_fpath:
            print('text_fpath.name = {!r}'.format(text_fpath.name))
            print(f'text={text}')
            ub.Path(text_fpath.name).write_text(text)
            GPGCLI.sign_file(src=text_fpath.name, dry=False,
                             sign_keyid=sign_keyid, verbose=verbose)

    @staticmethod
    def sign_and_encrypt_text(text, dst, sign_keyid, recipient=None, dry=False,
                              verbose=1):
        # Probably not secure
        if verbose:
            print('text = {!r}'.format(text))
        import tempfile
        text_fpath = tempfile.NamedTemporaryFile(mode='w', suffix='.txt')
        signed_text_fpath = tempfile.NamedTemporaryFile(mode='w', suffix='.signed.txt')

        assert recipient

        if sign_keyid == 'None':
            sign_keyid = None

        if verbose:
            print('text_fpath = {!r}'.format(text_fpath))
            print('signed_text_fpath = {!r}'.format(signed_text_fpath))
            print('text_fpath.name = {!r}'.format(text_fpath.name))
            print('signed_text_fpath.name = {!r}'.format(signed_text_fpath.name))

        with signed_text_fpath:

            with text_fpath:

                if not dry:
                    print('text_fpath.name = {!r}'.format(text_fpath.name))
                    ub.writeto(text_fpath.name, text, verbose=3)

                if sign_keyid is None or sign_keyid == 'None':
                    print('NO KEY ID GIVEN. Not SIGNING!')
                    next_src = text_fpath.name
                    v1 = None
                else:
                    next_src = signed_text_fpath.name
                    v1 = GPGCLI.sign_file(src=text_fpath.name,
                                          dst=next_src, dry=dry,
                                          sign_keyid=sign_keyid,
                                          verbose=verbose)
                if verbose:
                    print('v1 = {!r}'.format(v1))

                if recipient is None or recipient == 'None':
                    print('Not encrypting for anyone')
                    v2 = None
                    import shutil
                    shutil.copy(next_src, dst)
                else:
                    v2 = GPGCLI.encrypt_file(src=next_src, dst=dst,
                                             recipient=recipient, dry=dry,
                                             verbose=verbose)
                if verbose:
                    print('v2 = {!r}'.format(v2))
                if dry:
                    print(v1)
                    print(v2)
            # return [v1, v2]

    @staticmethod
    def encrypt_file(src, dst, recipient, dry=False, verbose=1):
        parts = [
            # Note we will encrypt a file for a user even if don't fully trust
            # them
            f'gpg --batch --yes --trust-model always --output {dst} --encrypt --armor --recipient {recipient} {src}',
        ]
        command = ' '.join(parts)
        if not dry:
            ub.delete(dst)
            ub.cmd(command, verbose=3)
            if verbose > 1:
                text = ub.readfrom(dst)
                print('text = {}'.format(text))
                print('dst = {!r}'.format(dst))
        else:
            return command

    @staticmethod
    def decrypt_file(src, dst, dry=False, verbose=1):
        parts = [
            # Note we will encrypt a file for a user even if don't fully trust
            # them
            f'gpg --decrypt --output {dst} {src}',
        ]
        command = ' '.join(parts)
        if not dry:
            ub.delete(dst, verbose=verbose > 1)
            ub.cmd(command, verbose=3, check=True)
            if verbose > 1:
                text = ub.readfrom(dst)
                print('text = {}'.format(text))
                print('dst = {!r}'.format(dst))
        else:
            return command

    @staticmethod
    def certify_key(signee, signer=None, check_level=None, dry=False):
        """
        Also known as "signing keys".
        """
        script_parts = [
            'gpg '
        ]

        if check_level is not None:
            script_parts.append('--ask-cert-level')

        if signer is not None:
            script_parts.append(f'--local-user={signer}!')
        script_parts.append(f'--sign-key {signee}!')

        script = _ExpectScript(' '.join(script_parts))

        if check_level is not None:
            check_level_lut = {
                'unknown': 0,
                'not': 1,
                'casual': 2,
                'careful': 3,
            }
            check_level_resp = check_level_lut.get(check_level, check_level)

            script - ("Your selection? (enter '?' for more information): ")
            script < str(check_level_resp)

        script - ('Really sign? (y/N) ')
        script < 'y'

        if dry:
            return script.finalize()
        else:
            script.execute()

    @staticmethod
    def upload_to_standard_keyservers(keyid):
        """
        keyid = GPGCLI.lookup_keyid('Jonathan Crall')
        """
        # import gpg_lite as gpg
        # gpg_store = gpg.GPGStore()
        # pub_key_ascii = gpg_store.export(keyid, armor=True)
        keyservers = [
            # 'keys.openpgp.org',
            'hkps://keys.openpgp.org',
            # 'hkp://pgp.mit.edu',  # dead
            # 'hkp://pool.sks-keyservers.net', # dead
            'hkps://keyserver.ubuntu.com',
        ]
        for keyserver in keyservers:
            # gpg.keyserver.upload_keys(pub_key_ascii, keyserver)
            ub.cmd(f'gpg --send-keys --keyserver {keyserver} {keyid}', verbose=2)


def main():
    import fire
    fire.Fire(GPGCLI)


if __name__ == '__main__':
    """
    CommandLine:
        python ~/local/scripts/xgpg.py
    """
    main()
