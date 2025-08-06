#!/bin/bash
#SBATCH --job-name=node-info
#SBATCH --account=gue998
#SBATCH --partition=compute
#SBATCH --reservation=si25cpu
#SBATCH --nodes=3
#SBATCH --ntasks=3
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=128
#SBATCH --mem=0
#SBATCH --time=00:05:00
#SBATCH --output=slurm-%j.out

export LOCAL_SCRATCH_DIR=$SLURM_TMPDIR

echo "🔧 Running on nodes:"
scontrol show hostname $SLURM_NODELIST

# Run staging and python in the same shell per node
srun --exact --ntasks=3 --ntasks-per-node=1 --unbuffered \
    bash -c 'source ./stage_condaenv.sh pythonhpc && exec python node_info.py'
