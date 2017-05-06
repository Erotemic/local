current=thesis
#A=7f1abb3c9d14c788d21a45bd6d15cbc6d5a825ea
#B=3fc99f3159dae6bb3daf4bcba8cea5ae570f920e

#A=3e218b5a78097923eb1945e41211fdb7cd7de98b
#B=c5248fca4eb75303d98f2c99a323b0f5ecf0a09d

A=b3449ba6d3118015d021646becc2889bd91444b5
B=574661ab5cdc00c5ab5abd9475c866e4a93ee5eb


"
from os.path import abspath
import git
repo = git.Repo(abspath('.'))

commit = repo.commit('HEAD')

# Find a chain of commits starting at the HEAD
chain = []
while len(commit.parents) == 1:
    chain.append(commit)
    commit = commit.parents[0]


# Find contiguous streaks
streaks = []
streak = []
streak_ids = []

valid_authors = {'joncrall'}

def continues_streak(streak, commit):
    if commit.author.name not in valid_authors:
        return False
    if len(streak) == 0:
        return True
    if streak[0].message == commit.message:
        date1 = streak[0].authored_datetime.date()
        date2 = commit.authored_datetime.date()
        if date1 == date2:
            return True
    return False

LEN_THRESH = 2
streak = []
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
        streak = []

temp_branchname = repo.active_branch.name + '-squash-temp'

# Switch to a temp branch
repo.git.checkout('HEAD', b=temp_branchname)
assert repo.active_branch.name == temp_branchname

ISO_8601 = '%Y-%m-%d %H:%M:%S %z'

for streak in streaks:
    # Start is the commit further back in time
    start = streak[-1]
    stop = streak[0]

    assert len(start.parents) == 1
    assert start.authored_datetime < stop.authored_datetime

    ts_start = start.authored_datetime.strftime(ISO_8601)
    ts_stop = stop.authored_datetime.strftime(ISO_8601)

    if ts_start.split()[0] == ts_stop.split()[0]:
        ts_stop_short = ts_stop.split()[1]
    else:
        ts_stop_short = ts_stop

    messages = ut.unique([commit.message for commit in streak])
    new_msg = '\n'.join(ut.unique(messages))
    if new_msg == 'wip\n':
        new_msg = new_msg.strip('\n') + ' - '
    new_msg += 'Squashed {} commits from {} to {}\n'.format(len(streak), 
                                                            ts_start, 
                                                            ts_stop_short)
    print(new_msg)

    # Go back in time to the sequence stopping point
    repo.git.reset(stop.hexsha, hard=True)
    # Undo commits from start to stop by softly reseting to just before the start
    before_start = start.parents[0]
    repo.git.reset(before_start.hexsha, soft=True)

    # Commit the changes in a new squashed commit and presever authored date
    repo.index.commit(new_msg, author_date=ts_stop_short)

    # Copy commits following the end of the streak in front of our new commit
    try:
        repo.git.cherry_pick(stop.hexsha + '..' + temp_branchname)
    except git.GitCommandError:
        print('need to roll back')
        raise

repo.git.branch(D=temp_branchname)
"


new_msg=$(git log $B^..$A --pretty=format:'%H' | python -c "
import sys
import utool as ut
hashes = sys.stdin.read().split('\n')
msg_list = []
for hash in hashes:
    msg = ut.cmd2('git log --format=%B -n 1 {}'.format(hash))['out']
    msg_list.append(msg)
#time1 = ut.cmd2('git log --format=%ci {} -n 1'.format(hashes[1]))['out'].strip()
#time2 = ut.cmd2('git log --format=%ci {} -n 1'.format(hashes[-1]))['out'].strip()
time1 = ut.cmd2('git log --format=%ci $B -n 1')['out'].strip()
time2 = ut.cmd2('git log --format=%ci $A -n 1')['out'].strip()
unique_msg = 'This is a combination of {} commits from {} to {}\n'.format(len(hashes), time1, time2)
unique_msg += '\n'.join(ut.unique(msg_list))
print(unique_msg)
")

echo "$new_msg"

# http://stackoverflow.com/questions/43815567/git-how-to-squash-all-commits-between-two-commits-into-a-single-commit/43816219#43816219

#backup=$current-squash-between-backup
temp=$current-squash-between-tmp

# Backup first
#git branch $backup $current
# Move to a temporary branch
git checkout -b $temp $current

# Go to the end of the sequence that we will sqush
git reset $A --hard
# Remove commits from the end to the begining of the sequence
git reset $B^ --soft

# Now commit that results as a new commit
git commit -m "$new_msg"

# Copy all the commits after the end of the sequence back in front of it
git cherry-pick $A..$current

# Our temp branch is now in the right state make the original branch point to this location
git checkout $current
git reset $temp --hard
git branch -D $temp
