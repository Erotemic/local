#!/usr/bin/env bash

# Force systemctl to startup slurm

sudo systemctl stop slurmctld slurmd
sudo systemctl reenable slurmctld slurmd
sudo systemctl restart slurmctld slurmd
sudo systemctl status slurmctld slurmd


_test(){
    srun echo "hi"
}

#sudo systemctl start slurmctld
#sudo systemctl start slurmd

#sudo systemctl start slurmctld
#sudo systemctl start slurmd
