#!/bin/bash

# Force systemctl to startup slurm

sudo systemctl enable slurmctld
sudo systemctl enable slurmd

sudo systemctl start slurmctld
sudo systemctl start slurmd
