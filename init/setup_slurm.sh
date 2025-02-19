#!/usr/bin/env bash
__doc__='
Script to help setup slurm.

This script is only meant to get slurm working for the use-case where a single
user is using it as a queue on a single system. In general slurm is much more
powerful and can provide resource managment across distributed systems. See
[1]_ for more details.  However, this script just sticks to the simple case.

This script was designed to be run interactively. In other words the user
should not simply execute this script blindly. Instead, the user should look at
each section, understand what it does, potentially modify it to their
specifications, and execute it explicitly.

To use it as a non-interactive script you can try...
    source ~/local/init/setup_slurm.sh && run_fresh_slurm_install

Requirements:
    Python 3.6+ available as the "python" command.

    pip install psutil ubelt --user

References:
    ..[1] https://slurm.schedmd.com/quickstart_admin.html

    ..[2] https://blog.llandsmeer.com/tech/2020/03/02/slurm-single-instance.html

    ..[3] https://wiki.fysik.dtu.dk/niflheim/SLURM
'

# ----------------------------------
# A subset of Jon Crall's bash utilities
# source ~/local/init/utils.sh

have_sudo(){
    __doc__='
    Tests if we have the ability to use sudo.
    Returns the string "True" if we do.

    References:
        https://stackoverflow.com/questions/18431285/check-if-a-user-is-in-a-group

    Example:
        HAVE_SUDO=$(have_sudo)
        if [ "$HAVE_SUDO" == "True" ]; then
            sudo do stuff
        else
            we dont have sudo
        fi
    '
    # New pure-bash implementation
    local USER_GROUPS
    USER_GROUPS=$(id -Gn "$(whoami)")
    if [[ " $USER_GROUPS " == *" sudo "* ]]; then
        echo "True"
    else
        echo "False"
    fi
}


sudo_writeto()
{
    fpath=$1
    fixed_text=$2
    sudo sh -c "echo \"$fixed_text\" > $fpath"
}

apt_ensure(){
    __doc__="
    Checks to see if the packages are installed and installs them if needed.

    The main reason to use this over normal apt install is that it avoids sudo
    if we already have all requested packages.

    Args:
        *ARGS : one or more requested packages

    Environment:
        UPDATE : if this is populated also runs and apt update

    Example:
        apt_ensure git curl htop
    "
    # Note the $@ is not actually an array, but we can convert it to one
    # https://linuxize.com/post/bash-functions/#passing-arguments-to-bash-functions
    ARGS=("$@")
    MISS_PKGS=()
    HIT_PKGS=()
    # Root on docker does not use sudo command, but users do
    if [ "$(whoami)" == "root" ]; then
        _SUDO=""
    else
        _SUDO="sudo "
    fi
    # shellcheck disable=SC2068
    for PKG_NAME in ${ARGS[@]}
    do
        #apt_ensure_single $EXE_NAME
        RESULT=$(dpkg -l "$PKG_NAME" | grep "^ii *$PKG_NAME")
        if [ "$RESULT" == "" ]; then
            echo "Do not have PKG_NAME='$PKG_NAME'"
            # shellcheck disable=SC2268,SC2206
            MISS_PKGS=(${MISS_PKGS[@]} "$PKG_NAME")
        else
            echo "Already have PKG_NAME='$PKG_NAME'"
            # shellcheck disable=SC2268,SC2206
            HIT_PKGS=(${HIT_PKGS[@]} "$PKG_NAME")
        fi
    done
    if [ "${#MISS_PKGS}" -gt 0 ]; then
        if [ "${UPDATE}" != "" ]; then
            $_SUDO apt update -y
        fi
        $_SUDO apt install -y "${MISS_PKGS[@]}"
    else
        echo "No missing packages"
    fi
}


codeblock()
{
    # Prevents python indentation errors in bash
    #python -c "from textwrap import dedent; print(dedent('$1').strip('\n'))"
    local PYEXE
    PYEXE=python3
    echo "$1" | $PYEXE -c "import sys; from textwrap import dedent; print(dedent(sys.stdin.read()).strip('\n'))"
}

pyblock(){
    __doc__='
    Executes python code and handles nice indentation.  Need to be slightly
    careful about the type of quotes used.  Typically stick to doublequotes
    around the code and singlequotes inside python code. Sometimes it will be
    necessary to escape some characters.'

    # Default values
    PYEXE=python3
    TEXT=""
    if [ $# -gt 1 ] && [[ $(type -P "$1") != "" ]] ; then
        # If the first arg executable, then assume it is a python executable
        PYEXE=$1
        # In this case the second arg must be text
        TEXT=$2
        # pop off these first two processed arguments, so the rest can be
        # passed to the python program
        shift
        shift
    else
        # Usually the first argument is text
        TEXT=$1
        # pop off this processed arguments, so the rest can be passed down
        shift
    fi
    $PYEXE -c "$(codeblock "$TEXT")" "$@"
}

# ----------------------------------

ensure_slurm_binaries(){
    ############################
    # INSTALL THE SLURM BINARIES
    ############################
    # Ensure the slurm packages are installed
    apt_ensure slurm slurm-client slurmctld slurmd slurmdbd slurm-wlm slurm-wlm-basic-plugins

    # On Ubuntu 21.10 installs slurm 20.11.4 this seems to install config and
    # files and make directories Trying to note them here
    __note__="

    Directories
        /var/lib/slurm
        ├── checkpoint
        ├── slurmctld
        └── slurmd
        /var/log/slurm

        /etc/slurm
        ├── plugstack.conf
        └── plugstack.conf.d


    Service Files:
        /lib/systemd/system/slurmctld.service
        /lib/systemd/system/slurmdbd.service
        /lib/systemd/system/slurmd.service
    "

    # Optional: install the slurm GUI
    #apt_ensure sview
}


setup_machine_hardware_variables(){
    __doc__="
    Define bash variables containing info about the machine hardware.
    These will be used to write default configurations.
    "
    ###################################################
    # INTROSPECT AND DEFINE VARIABLES ABOUT YOUR SYSTEM
    ###################################################

    # In this portion of the script we provide slurm information about this
    # system's file structure and hardware including RAM, CPUs, and GPUs.

    CONTROL_MACHINE=$HOSTNAME

    if lsb_release -a | grep "20.04" ; then
        IS_2004=True
    fi
    echo "IS_2004 = $IS_2004"

    if [[ "$IS_2004" == "True" ]]; then
        SLURM_LOG_DPATH=/var/log/slurm-llnl
        #SLURM_RUN_DPATH=/var/run/slurm-llnl
        SLURM_LIB_DPATH=/var/lib/slurm-llnl
        SLURM_ETC_DPATH=/etc/slurm-llnl
        SLURM_RUN_DPATH=/run
    else
        SLURM_LOG_DPATH=/var/log/slurm
        #SLURM_RUN_DPATH=/var/run/slurm
        SLURM_RUN_DPATH=/run
        SLURM_LIB_DPATH=/var/lib/slurm
        SLURM_ETC_DPATH=/etc/slurm
    fi

    # Hacky way of infering GPU info, may need to be tweaked
    # For example, a machine with 3 titanx gpus may look like:
    # NAME=gpu Type=CustomTagEgTitanX File=/dev/nvidia0
    # NAME=gpu Type=CustomTagEgTitanX File=/dev/nvidia1
    # NAME=gpu Type=CustomTagEgTitanX File=/dev/nvidia3
    SLURM_GRES_TEXT=$(pyblock "
    import ubelt as ub
    lines = ub.cmd('nvidia-smi -L')['out']

    cfglines = []
    for line in lines.split(chr(10)):
        if line:
            gputype = line.split(':')[1].split('(')[0].strip().replace(' ', '')
            # hack: is there a better way to determine the file?
            devfile = '/dev/nvidia{}'.format(len(cfglines))
            cfglines.append('NAME=gpu Type={} File={}'.format(gputype, devfile))
    gres_config_text = chr(10).join(cfglines)
    print(gres_config_text)
    ")

    # https://slurm.schedmd.com/gres.conf.html
    # TODO: Find a better way to introspect GPU information
    __dummy_example__="
    NAME=gpu Type=NVIDIAGeForceRTX3090 File=/dev/nvidia1
    "

    NUM_GPUS=$(echo "$SLURM_GRES_TEXT" | wc -l)

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


    # Hack
    NUM_SOCKETS=1

    # Note:
    # slurmd -C will print the physical configuration of the system
    ###########################
    # REPORT THE INFERED VALUES
    ###########################

    codeblock "
    CONTROL_MACHINE='$CONTROL_MACHINE'
    SLURM_LOG_DPATH='$SLURM_LOG_DPATH'
    SLURM_RUN_DPATH='$SLURM_RUN_DPATH'
    SLURM_LIB_DPATH='$SLURM_LIB_DPATH'
    SLURM_ETC_DPATH='$SLURM_ETC_DPATH'

    MAX_MEMORY='$MAX_MEMORY'

    # Note NUM_CPUS should be equal to NUM_SOCKETS * NUM_CORES * NUM_THREADS_PER_CORE
    NUM_CPUS='$NUM_CPUS'
    NUM_SOCKETS='$NUM_SOCKETS'
    NUM_CORES='$NUM_CORES'
    NUM_THREADS_PER_CORE='$NUM_THREADS_PER_CORE'

    NUM_GPUS='$NUM_GPUS'
    "
    printf "SLURM_GRES_TEXT =\n%s\n" "$SLURM_GRES_TEXT"
}

generate_slurm_config(){
    __doc__="
    source ~/local/init/setup_slurm.sh
    generate_slurm_config
    "
    ############################################
    # GENERATE REASONABLE DEFAULT CONFIGURATIONS
    ############################################
    echo "Checking for default slurm config"

    setup_machine_hardware_variables


    # This config is for newer versions of slurm
    # NEW
    if [[ "$IS_2004" == "True" ]]; then

        # TODO: Check where the installed slurm service files think the PIDs
        # should be and put the PID files there.

        SLURM_CONFIG_TEXT=$(codeblock "
            ControlMachine=$CONTROL_MACHINE
            ControlAddr=localhost
            AuthType=auth/munge
            CacheGroups=0
            CryptoType=crypto/munge
            GresTypes=gpu
            MpiDefault=none
            ProctrackType=proctrack/pgid
            ReturnToService=1
            SlurmctldPidFile=$SLURM_RUN_DPATH/slurmctld.pid
            SlurmctldPort=6817
            SlurmdPidFile=$SLURM_RUN_DPATH/slurmd.pid
            SlurmdPort=6818
            SlurmdSpoolDir=$SLURM_LIB_DPATH/slurmd
            SlurmUser=slurm
            StateSaveLocation=$SLURM_LIB_DPATH/slurmctld
            SwitchType=switch/none
            TaskPlugin=task/none
            InactiveLimit=0
            KillWait=30
            MinJobAge=7776000
            SlurmctldTimeout=120
            SlurmdTimeout=300
            Waittime=0
            SchedulerType=sched/backfill
            SchedulerPort=7321
            SelectType=select/cons_res
            SelectTypeParameters=CR_Core
            #AccountingStorageType=accounting_storage/filetxt
            AccountingStorageType=accounting_storage/none
            #AccountingStoreJobComment=YES
            ClusterName=cluster
            JobCompLoc=$SLURM_LOG_DPATH/completion.log
            JobCompType=jobcomp/filetxt
            JobAcctGatherFrequency=30
            JobAcctGatherType=jobacct_gather/linux
            SlurmctldDebug=3
            SlurmctldLogFile=$SLURM_LOG_DPATH/slurmctld.log
            SlurmdDebug=3
            SlurmdLogFile=$SLURM_LOG_DPATH/slurmd.log
            NodeName=$CONTROL_MACHINE Gres=gpu:$NUM_GPUS NodeAddr=localhost CPUs=$NUM_CPUS RealMemory=$MAX_MEMORY Sockets=$NUM_SOCKETS CoresPerSocket=$NUM_CORES ThreadsPerCore=$NUM_THREADS_PER_CORE State=UNKNOWN TmpDisk=223895
            PartitionName=bot Nodes=$CONTROL_MACHINE Default=NO MaxTime=INFINITE State=UP Priority=0
            PartitionName=mid Nodes=$CONTROL_MACHINE Default=NO MaxTime=INFINITE State=UP Priority=10
            PartitionName=top Nodes=$CONTROL_MACHINE Default=NO MaxTime=INFINITE State=UP Priority=100
            PartitionName=community Nodes=$CONTROL_MACHINE Default=YES MaxTime=INFINITE State=UP Priority=1
            PartitionName=priority Nodes=$CONTROL_MACHINE Default=YES MaxTime=INFINITE State=UP Priority=99
            PreemptType=preempt/partition_prio
            PreemptMode=REQUEUE
            ")
        #===============================
        # Ensure permissions are correct
        #===============================
        # Create the logdir
        echo "ensure SLURM_RUN_DPATH = $SLURM_RUN_DPATH"
        echo "ensure SLURM_LIB_DPATH = $SLURM_LIB_DPATH"
        echo "ensure SLURM_LOG_DPATH = $SLURM_LOG_DPATH"
        echo "ensure SLURM_ETC_DPATH = $SLURM_ETC_DPATH"
        sudo mkdir -p $SLURM_LOG_DPATH
        sudo mkdir -p $SLURM_RUN_DPATH
        sudo mkdir -p $SLURM_LIB_DPATH
        sudo mkdir -p $SLURM_ETC_DPATH
        #sudo mkdir -p $SLURMDBD_CONFIG_FPATH
        sudo chown -R slurm:slurm "$SLURM_LOG_DPATH"
        sudo chown -R slurm:slurm "$SLURM_LIB_DPATH"
        sudo chown -R slurm:slurm "$SLURM_RUN_DPATH"
        #sudo chown -R slurm:slurm "$SLURMDBD_CONFIG_FPATH"
        sudo chmod -R g+rw "$SLURM_LOG_DPATH"
    else
        SLURM_CONFIG_TEXT=$(codeblock "
        # slurm.conf file generated by configurator.html.
        # Put this file on all nodes of your cluster.
        # See the slurm.conf man page for more information.
        #
        ClusterName=cluster
        SlurmctldHost=toothbrush
        #SlurmctldHost=
        #
        GresTypes=gpu
        MpiDefault=none
        ProctrackType=proctrack/cgroup
        ReturnToService=1
        SlurmctldPidFile=/var/run/slurmctld.pid
        SlurmctldPort=6817
        SlurmdPidFile=/var/run/slurmd.pid
        SlurmdPort=6818
        SlurmdSpoolDir=/var/spool/slurmd
        SlurmUser=slurm
        StateSaveLocation=/var/spool/slurmctld
        SwitchType=switch/none
        TaskPlugin=task/affinity
        #
        # TIMERS
        InactiveLimit=0
        KillWait=30
        MinJobAge=300
        SlurmctldTimeout=120
        SlurmdTimeout=300
        Waittime=0
        #
        # SCHEDULING
        SchedulerType=sched/backfill
        SelectType=select/cons_tres
        SelectTypeParameters=CR_Core
        #
        # LOGGING AND ACCOUNTING
        AccountingStorageType=accounting_storage/none
        # AccountingStorageEnforce= disable accounting
        AccountingStoreFlags=job_comment
        JobCompType=jobcomp/none
        JobAcctGatherFrequency=30
        JobAcctGatherType=jobacct_gather/none
        SlurmctldDebug=info
        SlurmctldLogFile=/var/log/slurmctld.log
        SlurmdDebug=info
        SlurmdLogFile=/var/log/slurmd.log

        # COMPUTE NODES
        NodeName=$CONTROL_MACHINE Gres=gpu:$NUM_GPUS CPUs=$NUM_CPUS RealMemory=$MAX_MEMORY Sockets=$NUM_SOCKETS CoresPerSocket=$NUM_CORES ThreadsPerCore=$NUM_THREADS_PER_CORE State=UNKNOWN

        # Create named partitions with different priorities
        PartitionName=debug Nodes=ALL Default=YES MaxTime=INFINITE State=UP
        PartitionName=bot Nodes=$CONTROL_MACHINE Default=NO MaxTime=INFINITE State=UP Priority=0
        PartitionName=mid Nodes=$CONTROL_MACHINE Default=NO MaxTime=INFINITE State=UP Priority=10
        PartitionName=top Nodes=$CONTROL_MACHINE Default=NO MaxTime=INFINITE State=UP Priority=100
        PartitionName=community Nodes=$CONTROL_MACHINE Default=YES MaxTime=INFINITE State=UP Priority=1
        PartitionName=priority Nodes=$CONTROL_MACHINE Default=YES MaxTime=INFINITE State=UP Priority=99
        ")

        # Replaced new parts
        # NodeName=linux[1-32] CPUs=16 RealMemory=62943 Sockets=2 CoresPerSocket=8 ThreadsPerCore=2 State=UNKNOWN

        # These are the new locations that need fixed permissions
        sudo mkdir -p /var/spool/slurmd
        sudo mkdir -p /var/spool/slurmctld
        sudo chown slurm:slurm /var/spool/slurmd
        sudo chown slurm:slurm /var/spool/slurmctld
    fi

    SLURM_GRES_FPATH=$SLURM_ETC_DPATH/gres.conf
    SLURM_CONFIG_FPATH=$SLURM_ETC_DPATH/slurm.conf
    SLURM_CGROUP_FPATH=$SLURM_ETC_DPATH/cgroup.conf

    SLURM_CGROUP_TEXT=$(codeblock "
    CgroupAutomount=yes
    ConstrainCores=yes
    ConstrainRAMSpace=no
    ")
    if [ ! -f "$SLURM_CGROUP_FPATH" ] || [ "$SLURM_RESET_CONFIG_FLAG" ] ; then
        sudo_writeto $SLURM_CGROUP_FPATH "$SLURM_CGROUP_TEXT"
        echo "write to SLURM_CGROUP_FPATH = $SLURM_CGROUP_FPATH"
    else
        echo "already exists SLURM_CGROUP_FPATH = $SLURM_CGROUP_FPATH"
    fi

    # Dump configuration files if they dont exist
    if [ ! -f "$SLURM_GRES_FPATH" ] || [ "$SLURM_RESET_CONFIG_FLAG" ] ; then
        sudo_writeto $SLURM_GRES_FPATH "$SLURM_GRES_TEXT"
        echo "write to SLURM_GRES_FPATH = $SLURM_GRES_FPATH"
    else
        echo "already exists SLURM_GRES_FPATH = $SLURM_GRES_FPATH"
    fi
    if [ ! -f "$SLURM_CONFIG_FPATH" ] || [ "$SLURM_RESET_CONFIG_FLAG" ] ; then
        sudo_writeto $SLURM_CONFIG_FPATH "$SLURM_CONFIG_TEXT"
        echo "write to SLURM_CONFIG_FPATH = $SLURM_CONFIG_FPATH"
    else
        echo "already exists SLURM_CONFIG_FPATH = $SLURM_CONFIG_FPATH"
    fi

    #sudo chmod 600 "$SLURMDBD_CONFIG_FPATH"
    sudo chmod 644 "$SLURM_CONFIG_FPATH"
    sudo chmod 644 "$SLURM_GRES_FPATH"
    sudo chmod a+rX $SLURM_ETC_DPATH
    #sudo chmod 744 /etc/slurm-llnl/
    #sudo chmod -R 644 /etc/slurm-llnl/*
    #chmod -R a+rX /etc/slurm-llnl

}


slurm_extra_config(){

    # hack
    sudo chown slurm:slurm /var/spool/slurmd
    sudo chown slurm:slurm /var/spool/slurmctld

    SLURMDBD_CONFIG_TEXT=$(codeblock "
    AuthType=auth/munge
    DbdHost=localhost
    # DbdPort
    DebugLevel=info
    StorageHost=localhost
    StorageLoc=slurm_acct_db
    StoragePass=shazaam
    StorageType=accounting_storage/mysql
    StorageUser=slurm
    LogFile=$SLURM_LOG_DPATH/slurmdbd.log
    PidFile=$SLURM_RUN_DPATH/slurmdbd.pid
    SlurmUser=slurm
    ")

    # Create the logdir
    echo "ensure SLURM_RUN_DPATH = $SLURM_RUN_DPATH"
    echo "ensure SLURM_LIB_DPATH = $SLURM_LIB_DPATH"
    echo "ensure SLURM_LOG_DPATH = $SLURM_LOG_DPATH"
    echo "ensure SLURM_ETC_DPATH = $SLURM_ETC_DPATH"
    sudo mkdir -p "$SLURM_LOG_DPATH"
    sudo mkdir -p "$SLURM_RUN_DPATH"
    sudo mkdir -p "$SLURM_LIB_DPATH"
    sudo mkdir -p "$SLURM_ETC_DPATH"
    sudo mkdir -p "$SLURM_ETC_DPATH"

    SLURMDBD_CONFIG_FPATH=$SLURM_ETC_DPATH/slurmdbd.conf
    if [ ! -f "$SLURMDBD_CONFIG_FPATH" ] || [ "$SLURM_RESET_CONFIG_FLAG" ] ; then
        sudo_writeto "$SLURMDBD_CONFIG_FPATH" "$SLURMDBD_CONFIG_TEXT"
        echo "write to SLURMDBD_CONFIG_FPATH = $SLURMDBD_CONFIG_FPATH"
    else
        echo "already exists SLURMDBD_CONFIG_FPATH = $SLURMDBD_CONFIG_FPATH"
    fi
    sudo chmod 600 "$SLURMDBD_CONFIG_FPATH"

    SLURM_CGROUP_FPATH=$SLURM_ETC_DPATH/cgroup.conf
    SLURM_CGROUP_TEXT=$(codeblock "
    CgroupAutomount=yes
    CgroupReleaseAgentDir=/etc/slurm/cgroup
    ConstrainCores=yes
    ConstrainDevices=yes
    ConstrainRAMSpace=yes
    ")
    if [ ! -f "$SLURM_CGROUP_FPATH" ] || [ "$SLURM_RESET_CONFIG_FLAG" ] ; then
        sudo_writeto "$SLURM_CGROUP_FPATH" "$SLURM_CGROUP_TEXT"
        echo "write to SLURM_CGROUP_FPATH = $SLURM_CGROUP_FPATH"
    else
        echo "already exists SLURM_CGROUP_FPATH = $SLURM_CGROUP_FPATH"
    fi


    #===============================
    # Write the service file (I had one generated, this probably clobbers it, but it doesnt agree with config so lets try)
    #===============================
    #cat /lib/systemd/system/slurmctld.service
    #cat /lib/systemd/system/slurmdbd.service
    #cat /lib/systemd/system/slurmd.service

    # Settings I replaced in each
    #ConditionPathExists=/etc/slurm/slurm.conf
    #PIDFile=/run/slurmd.pid
    SLURMD_SERVICE_TEXT=$(codeblock "
    [Unit]
    Description=Slurm node daemon
    After=munge.service network.target remote-fs.target
    ConditionPathExists=$SLURM_CONFIG_FPATH
    Documentation=man:slurmd(8)

    [Service]
    Type=simple
    EnvironmentFile=-/etc/default/slurmd
    ExecStart=/usr/sbin/slurmd -D \$SLURMD_OPTIONS
    ExecReload=/bin/kill -HUP \$MAINPID
    PIDFile=$SLURM_RUN_DPATH/slurmd.pid
    KillMode=process
    LimitNOFILE=131072
    LimitMEMLOCK=infinity
    LimitSTACK=infinity
    Delegate=yes
    TasksMax=infinity

    [Install]
    WantedBy=multi-user.target
    ")

    SLURMCTLD_SERVICE_TEXT=$(codeblock "
    [Unit]
    Description=Slurm controller daemon
    After=network.target munge.service
    ConditionPathExists=$SLURM_CONFIG_FPATH
    Documentation=man:slurmctld(8)

    [Service]
    Type=simple
    EnvironmentFile=-/etc/default/slurmctld
    ExecStart=/usr/sbin/slurmctld -D \$SLURMCTLD_OPTIONS
    ExecReload=/bin/kill -HUP \$MAINPID
    PIDFile=$SLURM_RUN_DPATH/slurmctld.pid
    LimitNOFILE=65536
    TasksMax=infinity

    [Install]
    WantedBy=multi-user.target
    ")

    SLURMDBD_SERVICE_TEXT=$(codeblock "
    [Unit]
    Description=Slurm DBD accounting daemon
    After=network.target munge.service
    ConditionPathExists=$SLURM_CONFIG_FPATH
    Documentation=man:slurmdbd(8)

    [Service]
    Type=simple
    EnvironmentFile=-/etc/default/slurmdbd
    ExecStart=/usr/sbin/slurmdbd -D \$SLURMDBD_OPTIONS
    ExecReload=/bin/kill -HUP \$MAINPID
    PIDFile=$SLURM_RUN_DPATH/slurmdbd.pid

    LimitNOFILE=65536
    TasksMax=infinity

    [Install]
    WantedBy=multi-user.target
    ")

    sudo_writeto /lib/systemd/system/slurmd.service "$SLURMD_SERVICE_TEXT"
    sudo_writeto /lib/systemd/system/slurmctld.service "$SLURMCTLD_SERVICE_TEXT"
    sudo_writeto /lib/systemd/system/slurmdbd.service "$SLURMDBD_SERVICE_TEXT"
}

activate_slurm(){
    __doc__="
    Attempt to activate slurm via the systemd service files.

    On Ubuntu these are located in:
        /lib/systemd/system/slurmctld.service
        /lib/systemd/system/slurmdbd.service
        /lib/systemd/system/slurmd.service

    Note:
        The slurmctrld is the control daemon that would go on the machine
        that controls the entire cluser (which for us is just one machine)

        The slurmd is the slurm node daemon that manages the jobs on a single
        machine.

        The slurmdbd (accounting database daemon) is not needed if accounting
        is disabled.
    "
    #===============
    # Activate slurm
    #===============

    # NOTE: I'm not sure if this step works correctly.
    # A system reboot may be required.
    echo "[setup_slurm] activate_slurm"

    echo "[setup_slurm] activate_slurm - enable service"
    sudo systemctl enable slurmctld
    #sudo systemctl enable slurmdbd
    sudo systemctl enable slurmd

    echo "[setup_slurm] activate_slurm - start service"
    sudo systemctl start slurmctld
    #sudo systemctl start slurmdbd
    sudo systemctl start slurmd

    #echo "[setup_slurm] activate_slurm - restart service"
    #sudo systemctl restart slurmctld slurmdbd slurmd

    echo "[setup_slurm] activate_slurm - check status"
    systemctl status slurmctld slurmdbd slurmd -l --no-pager

    ##################################
    # Check to see if slurm is enabled
    ##################################
    echo "[setup_slurm] activate_slurm - check if enabled"
    systemctl list-unit-files | grep slurm
}


troubleshoot_slurm(){
    __doc__="
    Following [2]_ to troubleshoot issue with error: '

    srun: Required node not available (down, drained or reserved'.

    References:
        ..[2] https://slurm.schedmd.com/troubleshoot.html
    "
    # Double check everything wrote out correctly
    #cat /etc/slurm-llnl/gres.conf
    #pygmentize -l pacmanconf /etc/slurm-llnl/slurm.conf
    cat /etc/slurm/gres.conf
    pygmentize -l pacmanconf /etc/slurm/slurm.conf

    # Is the daemon running?
    pgrep slurmctld
    #ps -el | grep slurmctld

    # Are primary and backup controllers responding?
    scontrol ping

    # Check the log-dir for indications of failure
    #ls /var/log/slurm-llnl/
    ls /var/log/slurm/
    sudo cat /var/log/slurmd.log
    sudo cat /var/log/slurmctld.log

    # State of each partitions
    sinfo

    # If the states of the partitions are in drain, find out the reason
    sinfo -R

    # For "Low socket*core*thre" FIGURE THIS OUT

    # Undrain all nodes, first cancel all jobs
    # https://stackoverflow.com/questions/29535118/how-to-undrain-slurm-nodes-in-drain-state
    scancel --user="$USER"
    scancel --state=PENDING
    scancel --state=RUNNING
    scancel --state=SUSPENDED

    #sudo scontrol update nodename=namek state=idle
    sudo scontrol update nodename="$HOSTNAME" state=idle
}

_debug(){
    __doc__="
    Additional debugging commands. Used to develop and debug the setup script.
    Not used in production.
    "
    sudo vim /etc/slurm-llnl/slurm.conf

    # Manually start slurm host control and slurm node daemons
    sudo /usr/sbin/slurmctld -D -vvv
    #sudo /usr/sbin/slurmdbd -D -vvv
    sudo /usr/sbin/slurmd -D -vvv

    systemctl daemon-reload

    sudo systemctl restart slurmctld slurmd

    #
    sudo systemctl stop slurmd
    sudo systemctl disable slurmd
    sudo systemctl enable slurmd
    sudo systemctl start slurmd

    sudo systemctl stop slurmctld slurmd
    sudo systemctl disable slurmctld slurmd
    systemctl status slurmctld slurmd -l --no-pager

    sudo systemctl reenable slurmctld slurmd

    sudo systemctl restart  slurmd slurmctld
    systemctl status slurmctld slurmd -l --no-pager

    cat /lib/systemd/system/slurmctld.service
    cat /lib/systemd/system/slurmd.service
}


__purge_slurm_and_config__(){
    __doc__="
    Helper to get back into a clean state (This script broke between slurm versions)

    Not used in the main script. Helper used in development.
    "
    sudo systemctl stop slurmctld slurmd
    sudo systemctl disable slurmctld slurmd

    sudo apt-get purge slurm slurm-client slurmctld slurmd slurmdbd slurm-wlm slurm-wlm-basic-plugins

    tree /var/*/slurm*
    tree /etc/slurm*

    sudo rm -rf /var/run/slurm
    sudo rm -rf /var/log/slurm
    sudo rm -rf /var/lib/slurm

    sudo rm -rf /var/run/slurm-llnl/
    sudo rm -rf /var/log/slurm-llnl/
    sudo rm -rf /var/lib/slurm-llnl/

    ls -al /lib/systemd/system/*slurm*.service
    sudo rm -rf /lib/systemd/system/slurmd.service
    sudo rm -rf /lib/systemd/system/slurmdbd.service
    sudo rm -rf /lib/systemd/system/slurmctld.service

    ls -al /lib/systemd/system/slurm*.service
    #[ -d /etc/slurm ] && echo "should not exist"
    #[ -d /var/run/slurm ] && echo "should not exist"
    #[ -d /var/lib/slurm ] && echo "should not exist"
    #systemctl daemon-reload
}


slurm_usage_and_options(){
    __doc__="
    This shows a few things you can do with slurm.

    This is not part of the setup script.
    This is a set of commands you can use to demo / test that slurm is working.
    "

    # Check available partitions
    sinfo

    # Queue a job in the background
    mkdir -p "$HOME/.cache/slurm/logs"
    sbatch --job-name="test_job1" --output="$HOME/.cache/slurm/logs/job-%j-%x.out" --wrap="python -c 'import sys; sys.exit(1)'"
    sbatch --job-name="test_job2" --output="$HOME/.cache/slurm/logs/job-%j-%x.out" --wrap="echo 'hello'"

    #ls $HOME/.cache/slurm/logs
    ls -al "$HOME"/.cache/slurm/logs/*.out
    cat "$HOME"/.cache/slurm/logs/*.out

    # Queue a job (and block until completed)
    srun -c 2 -p top --gres=gpu:1 echo "hello"
    srun echo "hello"

    # List jobs in the queue
    squeue
    squeue --format="%i %P %j %u %t %M %D %R"

    # Show job with specific id (e.g. 6)
    scontrol show job 6

    # Cancel a job with a specific id
    scancel 6

    # Cancel all jobs from a user
    scancel --user="$USER"

    # You can setup complicated pipelines
    # https://hpc.nih.gov/docs/job_dependencies.html

    # Look at finished jobs
    # https://ubccr.freshdesk.com/support/solutions/articles/5000686909-how-to-retrieve-job-history-and-accounting

    # Note:
    # Slurm has to be configured with accounting for sacct to work.
    # This will not work if the slurmdbd is not running.

    # Jobs within since 3:30pm
    sudo sacct --starttime 15:35:00

    sudo sacct
    sudo sacct --format="JobID,JobName%30,Partition,Account,AllocCPUS,State,ExitCode,elapsed,start"
    sudo sacct --format="JobID,JobName%30,State,ExitCode,elapsed,start"


    # SHOW ALL JOBS that ran within MinJobAge
    scontrol show jobs
}


postinstall_test(){
    __doc__="
    Tests a few commands to check that the service is correctly running after
    install
    "

    sbatch  --job-name="test-job-name"     --output="test-job-output.txt"     --wrap 'echo "here we go"' --parsable
    squeue
}


run_fresh_slurm_install(){
    __doc__="
    Perform a fresh install of slurm.

    This is the main function of this script.

    Note: sudo is required.

    Usage:
        # First, authenticate as sudo (makes running the script smoother)
        sudo echo authenticate as sudo

        # Option 1:
        # Perform a fresh install. Does not overwrite existing config files.
        source ~/local/init/setup_slurm.sh

        # Option 2:
        # Perform a fresh install. Clobber and rewrite all config files.
        source ~/local/init/setup_slurm.sh && SLURM_RESET_CONFIG_FLAG=True run_fresh_slurm_install
    "
    sudo echo "authenticate as sudo"
    ensure_slurm_binaries
    generate_slurm_config
    activate_slurm
    postinstall_test
}



fix_issue_after_update(){
    __doc__="
    After upgrading to 24.04, it looks like there was an issue in the slurmctl.
    The main fatal error in the logs looked like:

    slurmctld: fatal: Can not recover last_tres state, incompatible version,
    got 9472 need >= 9728 <= 10240, start with '-i' to ignore this

    As the docs stated, it seemed to be fixed after running:

        sudo systemctl stop slurmctld
        sudo slurmctld -i
        sudo systemctl start slurmctld

    I suppose this just caused me to loose previous jobs, which is fine.

    References:
        https://chatgpt.com/c/67b4a23c-fe34-8013-baf7-59c0c8b2884c
    "
    sudo systemctl stop slurmctld
    sudo slurmctld -i
    sudo systemctl start slurmctld

    # Tried to remove spool files
    sudo rm -rf /var/spool/slurm*/*


    # oops, fix:
    sudo mkdir -p /var/spool/slurmctld /var/spool/slurmd
    # Set the correct ownership for the directories
    sudo chown slurm:slurm /var/spool/slurmd
    sudo chown slurm:slurm /var/spool/slurmctld
    # Set the correct permissions
    sudo chmod 751 /var/spool/slurmd
    sudo chmod 751 /var/spool/slurmctld


    sudo systemctl disable slurmdbd.service
    sudo systemctl restart slurmd slurmctld
    sudo systemctl status slurmd slurmctld

    journalctl -u slurmctld --no-pager | tail -50
    journalctl -u slurmdbd --no-pager | tail -50
    journalctl -u slurmd --no-pager | tail -50


    # Also try
    sudo apt install libpmix-dev

    sudo cat /var/log/slurmd.log

    # Stop systemctl service
    sudo systemctl stop slurmd slurmctld


    # Manually start slurm host control and slurm node daemons
    sudo /usr/sbin/slurmctld -D -vvv
    #sudo /usr/sbin/slurmdbd -D -vvv
    sudo /usr/sbin/slurmd -D -vvv

    scontrol show nodes

    # Also might need to
    # write to /etc/slurm/mpi.conf "
    # MpiDefault=pmix
    #  "

    # After a long time not getting very far, I ended up trying this:
    sudo scontrol update NodeName=ALL State=RESUME
    # and it got my node to start processing jobs again.


}
