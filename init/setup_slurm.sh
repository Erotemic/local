__heredoc__="""
Script to help setup slurm. 

This script is only meant to get slurm working for the use-case where a single
user is using it as a queue on a single system. In general slurm is much more
powerful and can provide resource managment across distributed systems. See
[1]_ for more details.  However, this script just sticks to the simple case.

This script was designed to be run interactively. In other words the user
should not simply execute this script blindly. Instead, the user should look at
each section, understand what it does, potentially modify it to their
specifications, and execute it explicitly. Executing blindly **might** work,
but it has not been tested, nor is it recommended.

Requirements:
    pip install psutil ubelt --user

References:
    ..[1] https://slurm.schedmd.com/quickstart_admin.html
"""

# ----------------------------------
# A subset of Jon Crall's bash utilities 
# source ~/local/init/utils.sh

sudo_writeto()
{
    fpath=$1
    fixed_text=$2
    sudo sh -c "echo \"$fixed_text\" > $fpath"
}
# ----------------------------------


###################################################
# INTROSPECT AND DEFINE VARIABLES ABOUT YOUR SYSTEM
###################################################

# In this portion of the script we provide slurm information about this
# system's file structure and hardware including RAM, CPUs, and GPUs.

CONTROL_MACHINE=$HOSTNAME
LOGDIR=/var/log/slurm-llnl

# Hacky way of infering GPU info, may need to be tweaked
# For example, a machine with 3 titanx gpus may look like:
# NAME=gpu Type=CustomTagEgTitanX File=/dev/nvidia0
# NAME=gpu Type=CustomTagEgTitanX File=/dev/nvidia1
# NAME=gpu Type=CustomTagEgTitanX File=/dev/nvidia3
GRES_CONFIG_TEXT=$(python -c """
import ubelt as ub
lines = ub.cmd('nvidia-smi -L')['out']

cfglines = []
for line in lines.split(chr(10)):
    if line:
        gputype = line.split(':')[1].split('(')[0].strip().replace(' ', '')
        # hack: is there a better way to determine the file?
        devfile = 'dev/nvidia{}'.format(len(cfglines))
        cfglines.append('NAME=gpu Type={} File={}'.format(gputype, devfile))
gres_config_text = chr(10).join(cfglines)
print(gres_config_text)
""")
# TODO: Find a better way to introspect GPU information

NUM_GPUS=$(echo "$GRES_CONFIG_TEXT" | wc -l)

# Use 95% of your RAM
# This variable should be in megabytes (e.g. 45988 ~= 45 GB)
#cat /proc/meminfo | grep MemTotal
MAX_MEMORY=$(python -c "import psutil; print(int(.95 * (psutil.virtual_memory().total - psutil.swap_memory().total) / 1e6))")

# Get information about CPUS
# Note: 
#lscpu | grep -E '^Thread|^Core|^Socket|^CPU\('
NUM_CPUS=$(cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l)
NUM_SOCKETS=$(lscpu | grep -E '^Thread' | awk '{split($0,a,":"); print a[2]}' | tr -d '[:space:]')
NUM_CORES=$(lscpu | grep -E '^Core' | awk '{split($0,a,":"); print a[2]}' | tr -d '[:space:]')
NUM_THREADS_PER_CORE=$(lscpu | grep -E '^Thread' | awk '{split($0,a,":"); print a[2]}' | tr -d '[:space:]')

# Note:
# slurmd -C will print the physical configuration of the system


###########################
# REPORT THE INFERED VALUES 
###########################

echo "CONTROL_MACHINE = $CONTROL_MACHINE"
echo "LOGDIR = $LOGDIR"
echo "MAX_MEMORY = $MAX_MEMORY"

# Note NUM_CPUS should be equal to NUM_SOCKETS * NUM_CORES * NUM_THREADS_PER_CORE 
echo "NUM_CPUS = $NUM_CPUS"
echo "NUM_SOCKETS = $NUM_SOCKETS"
echo "NUM_CORES = $NUM_CORES"
echo "NUM_THREADS_PER_CORE = $NUM_THREADS_PER_CORE"


echo "NUM_GPUS = $NUM_GPUS"
echo "GRES_CONFIG_TEXT = "
echo "$GRES_CONFIG_TEXT"


############################
# INSTALL THE SLURM BINARIES
############################

# Ensure the slurm packages are installed
sudo apt install slurm slurm-client slurmctld slurmd slurmdbd slurm-wlm slurm-wlm-basic-plugins  -y

# Optional: install the slurm GUI
sudo apt install sview -y


############################################
# GENERATE REASONABLE DEFAULT CONFIGURATIONS
############################################

# Create the logdir
sudo mkdir -p $LOGDIR

# Dump configuration files
sudo_writeto /etc/slurm-llnl/gres.conf "$GRES_CONFIG_TEXT"

sudo_writeto /etc/slurm-llnl/slurm.conf """
# slurm.conf file generated by configurator.html.
# Put this file on all nodes of your cluster.
# See the slurm.conf man page for more information.
#
ControlMachine=$CONTROL_MACHINE
ControlAddr=localhost
#BackupController=
#BackupAddr=
#
AuthType=auth/munge
CacheGroups=0
#CheckpointType=checkpoint/none
CryptoType=crypto/munge
#DisableRootJobs=NO
#EnforcePartLimits=NO
#Epilog=
#EpilogSlurmctld=
#FirstJobId=1
#MaxJobId=999999
GresTypes=gpu
#GroupUpdateForce=0
#GroupUpdateTime=600
#JobCheckpointDir=/var/lib/slurm-llnl/checkpoint
#JobCredentialPrivateKey=
#JobCredentialPublicCertificate=
#JobFileAppend=0
#JobRequeue=1
#JobSubmitPlugins=1
#KillOnBadExit=0
#LaunchType=launch/slurm
#Licenses=foo*4,bar
#MailProg=/usr/bin/mail
#MaxJobCount=5000
#MaxStepCount=40000
#MaxTasksPerNode=128
MpiDefault=none
#MpiParams=ports=#-#
#PluginDir=
#PlugStackConfig=
#PrivateData=jobs
ProctrackType=proctrack/pgid
#Prolog=
#PrologFlags=
#PrologSlurmctld=
#PropagatePrioProcess=0
#PropagateResourceLimits=
#PropagateResourceLimitsExcept=
#RebootProgram=
ReturnToService=1
#SallocDefaultCommand=
SlurmctldPidFile=/var/run/slurm-llnl/slurmctld.pid
SlurmctldPort=6817
SlurmdPidFile=/var/run/slurm-llnl/slurmd.pid
SlurmdPort=6818
SlurmdSpoolDir=/var/lib/slurm-llnl/slurmd
SlurmUser=slurm
#SlurmdUser=root
#SrunEpilog=
#SrunProlog=
StateSaveLocation=/var/lib/slurm-llnl/slurmctld
SwitchType=switch/none
#TaskEpilog=
TaskPlugin=task/none
#TaskPluginParam=
#TaskProlog=
#TopologyPlugin=topology/tree
#TmpFS=/tmp
#TrackWCKey=no
#TreeWidth=
#UnkillableStepProgram=
#UsePAM=0
#
#
# TIMERS
#BatchStartTimeout=10
#CompleteWait=0
#EpilogMsgTime=2000
#GetEnvTimeout=2
#HealthCheckInterval=0
#HealthCheckProgram=
InactiveLimit=0
KillWait=30
#MessageTimeout=10
#ResvOverRun=0
#MinJobAge=300
MinJobAge=7776000 # Keep job info for 90 days
#OverTimeLimit=0
SlurmctldTimeout=120
SlurmdTimeout=300
#UnkillableStepTimeout=60
#VSizeFactor=0
Waittime=0
#
#
# SCHEDULING
#DefMemPerCPU=0
FastSchedule=1
#MaxMemPerCPU=0
#SchedulerRootFilter=1
#SchedulerTimeSlice=30
SchedulerType=sched/backfill
SchedulerPort=7321
SelectType=select/cons_res
SelectTypeParameters=CR_Core
#
#
# JOB PRIORITY
#PriorityFlags=
#PriorityType=priority/basic
#PriorityDecayHalfLife=
#PriorityCalcPeriod=
#PriorityFavorSmall=
#PriorityMaxAge=
#PriorityUsageResetPeriod=
#PriorityWeightAge=
#PriorityWeightFairshare=
#PriorityWeightJobSize=
#PriorityWeightPartition=
#PriorityWeightQOS=
#
#
# LOGGING AND ACCOUNTING
#AccountingStorageEnforce=0
#AccountingStorageHost=
AccountingStorageLoc=$LOGDIR/accounting.log
#AccountingStoragePass=
#AccountingStoragePort=
AccountingStorageType=accounting_storage/filetxt
#AccountingStorageUser=
AccountingStoreJobComment=YES
ClusterName=cluster
#DebugFlags=
#JobCompHost=
JobCompLoc=$LOGDIR/completion.log
#JobCompPass=
#JobCompPort=
JobCompType=jobcomp/filetxt
#JobCompUser=
#JobContainerPlugin=job_container/none
JobAcctGatherFrequency=30
JobAcctGatherType=jobacct_gather/linux
SlurmctldDebug=3
SlurmctldLogFile=/var/log/slurm-llnl/slurmctld.log
SlurmdDebug=3
SlurmdLogFile=/var/log/slurm-llnl/slurmd.log
#SlurmSchedLogFile=
#SlurmSchedLogLevel=
#
#
# POWER SAVE SUPPORT FOR IDLE NODES (optional)
#SuspendProgram=
#ResumeProgram=
#SuspendTimeout=
#ResumeTimeout=
#ResumeRate=
#SuspendExcNodes=
#SuspendExcParts=
#SuspendRate=
#SuspendTime=
#
#
# COMPUTE NODES
NodeName=$CONTROL_MACHINE Gres=gpu:$NUM_GPUS NodeAddr=localhost CPUs=$NUM_CPUS RealMemory=$MAX_MEMORY Sockets=$NUM_SOCKETS CoresPerSocket=$NUM_CORES ThreadsPerCore=$NUM_THREADS_PER_CORE State=UNKNOWN TmpDisk=223895

# Hack in common groups
PartitionName=community Nodes=$CONTROL_MACHINE Default=YES MaxTime=INFINITE State=UP Priority=0
PartitionName=priority Nodes=$CONTROL_MACHINE Default=NO MaxTime=INFINITE State=UP Priority=10 
# AllowGroups=vigilant,slurm_priority
PartitionName=vigilant Nodes=$CONTROL_MACHINE Default=NO MaxTime=INFINITE State=UP Priority=100 
# AllowGroups=vigilant

# JOB PREEMPTION
PreemptType=preempt/partition_prio
PreemptMode=REQUEUE
"""


#===============================
# Ensure permissions are correct
#===============================

sudo chmod 644 /etc/slurm-llnl/slurm.conf
sudo chmod 644 /etc/slurm-llnl/gres.conf
#sudo chmod 744 /etc/slurm-llnl/
#sudo chmod -R 644 /etc/slurm-llnl/*
sudo chmod a+rX /etc/slurm-llnl
#chmod -R a+rX /etc/slurm-llnl



#===============
# Activate slurm
#===============

# NOTE: I'm not sure if this step works correctly.
# A system reboot may be required.
sudo systemctl enable slurmctld
sudo systemctl enable slurmdbd
sudo systemctl enable slurmd

sudo systemctl start slurmctld
sudo systemctl start slurmdbd
sudo systemctl start slurmd

#sudo systemctl stop slurmctld
#sudo systemctl stop slurmdbd
#sudo systemctl stop slurmd


##################################
# Check to see if slurm is enabled
##################################

systemctl list-unit-files | grep slurm


troubleshoot_slurm(){
    __heredoc__="""
    Following [2]_ to troubleshoot issue with error: '
    
    srun: Required node not available (down, drained or reserved'.

    References:
        ..[2] https://slurm.schedmd.com/troubleshoot.html
    """
    # Double check everything wrote out correctly
    cat /etc/slurm-llnl/gres.conf
    pygmentize -l pacmanconf /etc/slurm-llnl/slurm.conf

    # Are primary and backup controllers responding?
    scontrol ping

    # Check the log-dir for indications of failure
    ls /var/log/slurm-llnl/
    sudo cat /var/log/slurm-llnl/slurmd.log
    sudo cat /var/log/slurm-llnl/slurmctld.log

    # Is the daemon running?
    ps -el | grep slurmctld

    # State of each partitions
    sinfo

    # If the states of the partitions are in drain, find out the reason
    sinfo -R

    # For "Low socket*core*thre" FIGURE THIS OUT

    # Undrain all nodes, first cancel all jobs
    # https://stackoverflow.com/questions/29535118/how-to-undrain-slurm-nodes-in-drain-state
    scancel --user=$USER
    scancel --state=PENDING
    scancel --state=RUNNING
    scancel --state=SUSPENDED

    sudo scontrol update nodename=namek state=idle
}


slurm_usage_and_options(){
    __heredoc__="""
    This shows a few things you can do with slurm
    """

    # Queue a job in the background
    mkdir -p $HOME/.cache/slurm/logs
    sbatch --job-name="test_job1" --output="$HOME/.cache/slurm/logs/job-%j-%x.out" --wrap="python -c 'import sys; sys.exit(1)'"
    sbatch --job-name="test_job2" --output="$HOME/.cache/slurm/logs/job-%j-%x.out" --wrap="echo 'hello'"

    #ls $HOME/.cache/slurm/logs
    cat $HOME/.cache/slurm/logs/test_echo.log

    # Queue a job (and block until completed)
    srun -c 2 -p priority --gres=gpu:1 echo "hello"
    srun echo "hello"

    # List jobs in the queue
    squeue
    squeue --format="%i %P %j %u %t %M %D %R"

    # Show job with specific id (e.g. 6)
    scontrol show job 6

    # Cancel a job with a specific id
    scancel 6

    # Cancel all jobs from a user 
    scancel --user=$USER

    # You can setup complicated pipelines
    # https://hpc.nih.gov/docs/job_dependencies.html

    # Look at finished jobs
    # https://ubccr.freshdesk.com/support/solutions/articles/5000686909-how-to-retrieve-job-history-and-accounting

    # Jobs within since 3:30pm
    sudo sacct --starttime 15:35:00 

    sudo sacct
    sudo sacct --format="JobID,JobName%30,Partition,Account,AllocCPUS,State,ExitCode,elapsed,start"
    sudo sacct --format="JobID,JobName%30,State,ExitCode,elapsed,start"


    # SHOW ALL JOBS that ran within MinJobAge
    scontrol show jobs
}
