#!/usr/bin/env python
"""
Notes:
    /etc/slurm-llnl/slurm.conf
    /etc/slurm-llnl/gres.conf
"""
import sys
import io
import getpass
import time
import readline
import glob
from os.path import exists
import scriptconfig as scfg

import ubelt as ub
import pandas as pd

WIN32 = sys.platform.startswith('win32')
if WIN32:
    from win32api import STD_INPUT_HANDLE
    from win32console import GetStdHandle, KEY_EVENT, ENABLE_ECHO_INPUT, ENABLE_LINE_INPUT, ENABLE_PROCESSED_INPUT
else:
    import sys
    import select
    import termios


class SlurmMonitorConfig(scfg.DataConfig):
    initial = scfg.Value(None, help='initial command to run', position=1)


class KeyPoller():
    """
    References:
        https://stackoverflow.com/questions/13207678/whats-the-simplest-way-of-detecting-keyboard-input-in-python-from-the-terminal
        https://stackoverflow.com/a/22398481
    """
    def __enter__(self):
        if WIN32:
            self.readHandle = GetStdHandle(STD_INPUT_HANDLE)
            self.readHandle.SetConsoleMode(ENABLE_LINE_INPUT | ENABLE_ECHO_INPUT | ENABLE_PROCESSED_INPUT)

            self.curEventLength = 0
            self.curKeysLength = 0

            self.capturedChars = []
        else:
            # Save the terminal settings
            self.fd = sys.stdin.fileno()
            self.new_term = termios.tcgetattr(self.fd)
            self.old_term = termios.tcgetattr(self.fd)

            # New terminal setting unbuffered
            self.new_term[3] = (self.new_term[3] & ~termios.ICANON & ~termios.ECHO)
            # termios.tcsetattr(self.fd, termios.TCSAFLUSH, self.new_term)
            termios.tcsetattr(self.fd, termios.TCSADRAIN, self.new_term)

        return self

    def __exit__(self, type, value, traceback):
        if not WIN32:
            # termios.tcsetattr(self.fd, termios.TCSAFLUSH, self.old_term)
            termios.tcsetattr(self.fd, termios.TCSADRAIN, self.old_term)

    def poll(self):
        if WIN32:
            if not len(self.capturedChars) == 0:
                return self.capturedChars.pop(0)

            eventsPeek = self.readHandle.PeekConsoleInput(10000)

            if len(eventsPeek) == 0:
                return None

            if not len(eventsPeek) == self.curEventLength:
                for curEvent in eventsPeek[self.curEventLength:]:
                    if curEvent.EventType == KEY_EVENT:
                        if ord(curEvent.Char) == 0 or not curEvent.KeyDown:
                            pass
                        else:
                            curChar = str(curEvent.Char)
                            self.capturedChars.append(curChar)
                self.curEventLength = len(eventsPeek)

            if not len(self.capturedChars) == 0:
                return self.capturedChars.pop(0)
            else:
                return None
        else:
            # TODO: Figure out how to capture page-up page-down effectively
            # THey seem to be broken into sequences of characters
            dr, dw, de = select.select([sys.stdin], [], [], 0)
            if not dr == []:
                return sys.stdin.read(1)
            return None

    @classmethod
    def demo(KeyPoller):
        """
        CommandLine:
            xdoctest -m ~/local/bin/slurm_monitor_jobs.py KeyPoller.demo

        Example:
            >>> KeyPoller.demo()
        """

        with KeyPoller() as keyPoller:
            prev = None
            while True:
                key = keyPoller.poll()
                if key != prev:
                    print('NEW key = {!r}'.format(key))
                if key:
                    if key == "c":
                        break
                    print('key = {!r}'.format(key))
                prev = key


class TermOption:
    def __init__(self, name, help=''):
        self.name = name
        self.help = help


class TermInput(object):
    """
    Read user input from a terminal with tab completions.

    References:
        http://stackoverflow.com/questions/5637124/tab-completion-in-pythons-raw-input
        https://gist.github.com/iamatypeofwalrus/5637895
    """

    def __init__(self, options=None, path=None):
        self.options = options
        self.path = path

    def input(self, msg='> '):
        readline.set_completer_delims('\t')
        readline.parse_and_bind("tab: complete")
        readline.set_completer(self._complete)
        ans = input(msg)
        return ans

    def print_help(self):
        for opt in self.options:
            print(f'{opt.name} - {opt.help}')

    def _complete(self, text, state):
        completions = []
        if self.options:
            # Tab complete custom options
            opts = [c.name if isinstance(c, TermOption)
                    else c for c in self.options]
            opts = list(map(str, opts))
            if not text:
                completions += [c for c in opts]
            else:
                completions += [c for c in opts if c.startswith(text)]
        if self.path:
            # This is the tab completer for systems paths.
            matches = list(glob.glob(text + '*'))
            completions += matches
        return completions[state]

    @classmethod
    def demo(TermInput):
        completer = TermInput(path=True)
        print('You can complete system paths')
        import os
        print(os.listdir('.'))
        ans = completer.input('>')
        print('ans = {!r}'.format(ans))


class Slurm:
    """
    Simple Slurm API

    Ignore:
        >>> # Cancel pending jobs
        >>> import sys, ubelt
        >>> sys.path.append(ubelt.expandpath('~/local/bin'))
        >>> from slurm_monitor_jobs import *  # NOQA
        >>> table = Slurm.queue_info()
        >>> pending_jobs = table[table['ST'] == 'PD']
        >>> text = ' '.join(list(map(str, pending_jobs['JOBID'])))
        >>> ub.cmd('scancel ' + text, shell=True)
    """
    JOB_STATE_CODES = {
        'BF': 'BOOT_FAIL',
        'CA': 'CANCELLED',
        'CD': 'COMPLETED',
        'CF': 'CONFIGURING',
        'CG': 'COMPLETING',
        'F' : 'FAILED',
        'NF': 'NODE_FAIL',
        'PD': 'PENDING',
        'PR': 'PREEMPTED',
        'RV': 'REVOKED',
        'R': 'RUNNING',
        'SE': 'SPECIAL_EXIT',
        'ST': 'STOPPED',
        'S' : 'SUSPENDED',
        'TO': 'TIMEOUT',
    }

    @staticmethod
    def _parse_show_job(block):
        data = {}
        for line in block.splitlines():
            parts = line.strip().split(' ')
            for part in parts:
                if part:
                    key, *rest = part.split('=')
                    val = '='.join(rest)
                    data[key.strip()] = val.strip()

        for k in ['StdErr', 'StdOut']:
            if k in data:
                # Replace control keys with special values
                data[k] = data[k].replace('%x', data['JobName'])
        return data

    @staticmethod
    def queue_info():
        if not ub.find_exe('squeue'):
            raise FileNotFoundError('Cannot find squeue. Is Slurm installed?')
        info = ub.cmd('squeue --format="%i %P %j %u %t %M %D %R"')
        stream = io.StringIO(info['out'])
        df = pd.read_csv(stream, sep=' ')

        # if True:
        #     out_fpaths = []
        #     for jobid in df['JOBID']:
        #         try:
        #             fpath = ub.shrinkuser(Slurm.job_info(jobid)['StdOut'])
        #         except Exception:
        #             fpath = None
        #         out_fpaths.append(fpath)
        #     df['StdOut'] = out_fpaths

        if False:
            # Parse out info about finished jobs
            info = ub.cmd('scontrol show jobs')
            if not info['out'].startswith('No jobs in the system'):
                blocks = info['out'].split('\n\n')
                job_blocks = []
                for block in blocks:
                    data = Slurm._parse_show_job(info['out'])
                    job_blocks.append(data)

                df2 = pd.DataFrame.from_dict(job_blocks, orient='columns')

                state_to_code = ub.invert_dict(Slurm.JOB_STATE_CODES)

                newcols = {
                    'JOBID': df2['JobId'],
                    'ST': df2['JobState'].apply(lambda x: state_to_code[x]),
                    'USER': df2['UserId'].apply(lambda x: x.split('(')[0]),
                    'STDOUT': df2['StdOut'],
                }
                df = pd.DataFrame.from_dict(newcols, orient='columns')
        return df

    @staticmethod
    def my_queue_info():
        df = Slurm.queue_info()
        user = getpass.getuser()
        myjobs = df[df['USER'] == user]
        return myjobs

    @staticmethod
    def jobids():
        """
        Get the current user's jobs

        Example:
            >>> Slurm.jobids()
        """
        myjobs = Slurm.queue_info()
        # running_jobs = myjobs[myjobs['ST'] == 'R']
        # jobids = running_jobs['JOBID'].values.tolist()
        jobids = myjobs['JOBID'].values.tolist()
        return jobids

    @staticmethod
    def job_info(jobid):
        """
        Get info about a job
        """
        if not ub.find_exe('scontrol'):
            raise FileNotFoundError(
                'Cannot find scontrol. Is Slurm installed?')
        info = ub.cmd('scontrol show job ' + str(jobid))
        data = Slurm._parse_show_job(info['out'])
        return data

    @staticmethod
    def watch(jobid, n=1.0):
        r"""
        Display output from a running job in realtime

        References:
            https://stackoverflow.com/questions/3290292/read-log-as-written

        Ignore:
            slurm -c 2 -p priority --gres=gpu:1 python -m harn.predict --animate=True --draw=True \
                    --scenes=special:test \
                    --step=8,3,3 \
                    --deployed=~/remote/foo.zip \
                    --out_dpath=~/remote/work/bar/eval/final
        """
        data = Slurm.job_info(jobid)
        print('WATCHING jobid={}'.format(jobid))
        try:
            fpath = data['StdOut']
            print('WATCHING fpath = {!r}'.format(fpath))
        except KeyError:
            print('ERROR data = {}'.format(ub.repr2(data, nl=1)))
            print('Job was likely submitted through srun and is viewable in a terminal')
            raise NoStdout('jobs was not submitted using sbatch')

        class FileWatcher(object):
            def __init__(self, fpath):
                self.fpath = fpath
                self.file = None
                self._show_exist_msg = True

            def __enter__(self):
                return self

            def __exit__(self, a, b, c):
                if self.file is not None:
                    self.file.close()
                    self.file = None

            def check_event(self):
                if self.file is None:
                    if exists(self.fpath):
                        self.file = open(self.fpath, 'rb')
                    else:
                        if self._show_exist_msg:
                            print('File "{}" doesnt yet exist'.format(self.fpath))
                            self._show_exist_msg = False
                        return False

                where = self.file.tell()
                line = self.file.readline()
                if not line:
                    self.file.seek(where)
                    return False
                else:
                    sys.stdout.write(line.decode('utf8'))
                    return True

        with FileWatcher(fpath) as watcher:
            with KeyPoller() as keyPoller:

                timer = ub.Timer()
                timer.tic()

                KEY_CTRL_B = chr(2)  # '\x02'
                KEY_ESC = chr(27)  # '\x1b'

                have_ctrl_b = False
                while True:
                    awake = True

                    if not have_ctrl_b:
                        awake &= watcher.check_event()

                    if timer.toc() > 0.1:
                        key = keyPoller.poll()
                        if key is not None:
                            # print('key = {!r}'.format(key))

                            if key == KEY_ESC:
                                return 'stop'

                            if key == KEY_CTRL_B:
                                awake = True
                                have_ctrl_b = True
                                # print('HAVE CTRL B')
                                # print('jobid = {!r}'.format(jobid))

                            elif have_ctrl_b:
                                # print('key = {!r}'.format(key))
                                if key in {'(', '['}:
                                    return 'prev'
                                elif key in {')', ']'}:
                                    return 'next'
                                elif key == 'x':
                                    return 'stop'
                                else:
                                    # print('NO LONGER HAVE CTRL B')
                                    have_ctrl_b = False
                        timer.tic()

                    if not awake:
                        time.sleep(n)


class FileWatcher2:
    """
    Example:
        >>> import sys, ubelt
        >>> sys.path.append(ubelt.expandpath('~/local/bin'))
        >>> from slurm_monitor_jobs import *  # NOQA
        >>> fpath = '/home/joncrall/.cache/slurm_queue/schedule-eval-20220315T005718-87da3791/logs/J0008-schedule-eval-20220315T005718-87da3791.sh'
        >>> self = FileWatcher2(fpath)
        >>> self.check_event()
    """
    def __init__(self, fpath):
        from collections import deque
        self.fpath = fpath
        self.file = None
        self.buffer = deque()

    def __enter__(self):
        return self

    def __exit__(self, a, b, c):
        if self.file is not None:
            self.file.close()
            self.file = None

    def _open(self):
        if exists(self.fpath):
            self.file = open(self.fpath, 'rb')
        else:
            raise FileNotFoundError(f'File "{self.fpath}" doesnt yet exist')

    def check_event(self):
        if self.file is None:
            self._open()

        where = self.file.tell()
        line = self.file.readline()
        if not line:
            self.file.seek(where)
            return False
        else:
            self.buffer.append(line.decode('utf8'))
            return True


def rwatch():
    """
    Watch with rich

    CommandLine:
        xdoctest -m $HOME/local/bin/slurm_monitor_jobs.py rwatch
    """
    from rich.__main__ import make_test_card
    from rich.console import Console

    console = Console()
    with console.pager():
        console.print(make_test_card())


def monitor(refresh_rate=0.4):
    """
    Monitor progress until the jobs are done
    """

    import time
    from rich.live import Live
    from rich.table import Table
    import io
    import pandas as pd
    jobid_history = set()

    def update_status_table():
        # https://rich.readthedocs.io/en/stable/live.html
        info = ub.cmd('squeue --format="%i %P %j %u %t %M %D %R"')
        stream = io.StringIO(info['out'])
        df = pd.read_csv(stream, sep=' ')
        jobid_history.update(df['JOBID'])

        num_running = (df['ST'] == 'R').sum()
        num_in_queue = len(df)
        num_total = len(jobid_history)

        table = Table(*['num_running', 'num_in_queue', 'total_monitored'],
                      title='slurm-monitor')

        # TODO: determine if slurm has accounting on, and if we can
        # figure out how many jobs errored / passed

        table.add_row(
            f'{num_running}',
            f'{num_in_queue}',
            f'{num_total}'
        )

        finished = (num_in_queue == 0)
        return table, finished

    table, finished = update_status_table()
    refresh_rate = 0.4
    with Live(table, refresh_per_second=4) as live:
        while not finished:
            time.sleep(refresh_rate)
            table, finished = update_status_table()
            live.update(table)


class NoStdout(Exception):
    pass


def main():

    config = SlurmMonitorConfig.cli(cmdline=True)
    initial = config['initial']

    # TODO: This should becoma a textual application

    index = -1
    # print(Slurm.queue_info().to_string())
    while True:
        alljobs = Slurm.queue_info()
        jobids = alljobs['JOBID'].values.tolist()
        running_jobids = alljobs[alljobs['ST'] == 'R']['JOBID'].values.tolist()
        # jobids = Slurm.jobids()
        print('\n--------')
        print('Select a jobid or enter a command')
        options = [
            TermOption('quit', help='exit the monitor program'),
            TermOption('list', help='list the queue'),
            TermOption('next', help='goto the next job'),
            TermOption('prev', help='goto the previous job'),
            TermOption('embed', help='ipython prompt'),
        ]
        # options += [
        #     TermOption(str(j)) for j in jobids
        # ]
        tty = TermInput(options=options)
        if initial is None:
            ans = tty.input()
        else:
            ans = initial
            initial = None

        if ans == '':
            tty.print_help()
            print('use "exit" to exit or "ls" to list')
            continue
        if ans == 'list' or ans == 'ls':
            print(Slurm.queue_info().to_string())
            continue
        if ans == 'info':
            for jobid in jobids:
                print('jobid = {!r}'.format(jobid))
                info = Slurm.job_info(jobid)
                print(ub.repr2(info, nl=1))
                print('-----')
            continue

        if ans == 'kill':
            ub.cmd('scancel --user=$USER')
            break
        if ans == 'quit' or ans == 'exit' or ans == 'q':
            break
        if ans == 'embed':
            import IPython
            IPython.embed()
            break
        elif ans == 'running' or ans == 'r':
            queue_info = Slurm.queue_info()
            running = queue_info[queue_info['ST'] == 'R']
            if len(running) == 0:
                print('no running jobs')
                continue
            jobid = running['JOBID'].iloc[0]
        elif ans == 'next' or ans == 'n':
            index = (index + 1) % len(running_jobids)
            jobid = running_jobids[index]
        elif ans == 'prev' or ans == 'p':
            index = (index - 1) % len(running_jobids)
            jobid = running_jobids[index]
        else:
            try:
                jobid = int(ans)
                if jobid not in jobids:
                    jobid = jobids[jobid]
                index = jobids.index(jobid)
            except Exception:
                print('invalid command')
                continue

        try:
            while True:
                try:
                    special = Slurm.watch(jobid, n=0.33)
                except NoStdout:
                    print('Cannot watch jobid={}'.format(jobid))
                    special = None

                alljobs = Slurm.queue_info()
                running_jobids = alljobs[alljobs['ST'] == 'R']['JOBID'].values.tolist()

                if special == 'next':
                    index = (index + 1) % len(running_jobids)
                    jobid = running_jobids[index]
                elif special == 'prev':
                    index = (index - 1) % len(running_jobids)
                    jobid = running_jobids[index]
                elif special == 'stop':
                    break
                else:
                    break
        except KeyboardInterrupt:
            pass


if __name__ == '__main__':
    """
    CommandLine:
        python ~/local/bin/slurm_monitor_jobs.py
    """

    main()
    # TermInput.demo()
