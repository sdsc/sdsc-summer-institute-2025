#!/usr/bin/env bash

#SBATCH --job-name=run-pi-workflow
#SBATCH --account=gue998
#SBATCH --reservation=si24
#SBATCH --partition=shared
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00:30:00
#SBATCH --output=%x.o%j.%N

module reset

job_id="$(sbatch estimate-pi.sh | grep -o '[[:digit:]]*')"
sbatch "--dependency=afterok:${job_id}" compute-pi-stats.sh
