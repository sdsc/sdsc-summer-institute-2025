#!/usr/bin/env bash

#SBATCH --job-name=estimate-pi
#SBATCH --account=gue998
#SBATCH --reservation=si25cpu
#SBATCH --partition=shared
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00:30:00
#SBATCH --output=%x.o%j.%N

module purge

time -p "${HOME}/4pi/bash/pi.sh" -b 8 -r 5 -s 10000
