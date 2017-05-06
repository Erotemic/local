import os
import git
import ubelt as ub

repo = git.Repo(os.getcwd())
orig_branch_name = repo.active_branch.name

head = repo.commit('HEAD')

# Find a chain of commits starting at the HEAD
chain = []
commit = head
while len(commit.parents) == 1:
    chain.append(commit)
    commit = commit.parents[0]

if len(chain) == 0:
    raise ValueError('No continuous commits exist')


# Find contiguous streaks
class Streak(ub.NiceRepr):
    def __init__(self, child, streak):
        self.child = child
        self._streak = streak

    def __iter__(self):
        return iter(self._streak)

    def __nice__(self):
        return 'num={}'.format(len(self))

    def __len__(self):
        return len(self._streak)

    def append(self, commit):
        self._streak.append(commit)

    @property
    def before_start(self):
        assert len(self.start.parents) == 1
        return self.start.parents[0]

    @property
    def after_stop(self):
        return self.child

    @property
    def start(self):
        return self._streak[-1]

    @property
    def stop(self):
        return self._streak[0]

streaks = []
streak_ids = []

valid_authors = {'joncrall'}

def continues_streak(streak, commit):
    if commit.author.name not in valid_authors:
        return False
    if len(streak) == 0:
        return True
    if streak.start.message == commit.message:
        date1 = streak.start.authored_datetime.date()
        date2 = commit.authored_datetime.date()
        if date1 == date2:
            return True
    return False

LEN_THRESH = 2
child = None
streak = Streak(child, [])
for commit in chain:
    if continues_streak(streak, commit):
        streak.append(commit)
    else:
        # Streak is broken
        if len(streak) < LEN_THRESH:
            streak_ids.extend([None] * max(1, len(streak)))
        else:
            streaks.append(streak)
            streak_ids.extend([len(streaks)] * len(streak))
        child = commit
        streak = Streak(child, [])

temp_branchname = repo.active_branch.name + '-squash-temp'

# Switch to a temp branch
print('Switching to temporary branch')
try:
    repo.git.checkout('HEAD', b=temp_branchname)
except git.GitCommandError as ex:
    err = str(ex)
    if 'branch named' in err and 'already exists' in err:
        print('... Deleting old temporary branch')
        # Delete the old temp branch
        repo.git.branch(D=temp_branchname)
        repo.git.checkout('HEAD', b=temp_branchname)
    else:
        raise

assert repo.active_branch.name == temp_branchname

ISO_8601 = '%Y-%m-%d %H:%M:%S %z'
import email.utils

new_head = head

for streak in ub.ProgIter(streaks, 'squashing'):
    print('Squashing streak = %r' % (str(streak),))
    # Start is the commit further back in time
    start = streak.start
    stop = streak.stop

    assert len(start.parents) == 1
    assert start.authored_datetime < stop.authored_datetime

    # Do RFC2822
    # ts_start = start.authored_datetime.strftime(ISO_8601)
    # ts_stop = stop.authored_datetime.strftime(ISO_8601)
    ts_start = email.utils.format_datetime(start.authored_datetime)
    ts_stop = email.utils.format_datetime(stop.authored_datetime)

    if ts_start.split()[0:4] == ts_stop.split()[0:4]:
        ts_stop_short = ' '.join(ts_stop.split()[4:])
    else:
        ts_stop_short = ts_stop
    # Construct a new message
    messages = [commit.message for commit in streak._streak]
    unique_messages = ub.unique(messages)
    new_msg = '\n'.join(unique_messages)
    if new_msg == 'wip\n':
        new_msg = new_msg.strip('\n') + ' - '
    new_msg += 'Squashed {} commits from {} to {}\n'.format(
        len(streak), ts_start, ts_stop_short)

    # Go back in time to the sequence stopping point
    repo.git.reset(stop.hexsha, hard=True)
    # Undo commits from start to stop by softly reseting to just before the start
    before_start = start.parents[0]
    repo.git.reset(before_start.hexsha, soft=True)

    # Commit the changes in a new squashed commit and presever authored date
    repo.index.commit(new_msg, author_date=ts_stop)

    if streak.child is not None:
        # Copy commits following the end of the streak in front of our new commit
        try:
            above = stop.hexsha + '..' + new_head.hexsha
            # above = streak.child.hexsha + '..' + new_head
            repo.git.cherry_pick(above, allow_empty=True)
        except git.GitCommandError:
            print('need to roll back')
            raise
    # Maintain the new head with squashed commits in its history
    new_head = repo.commit('HEAD')

if False:
    repo.git.checkout(orig_branch_name)
    repo.git.branch(D=temp_branchname)
    break
