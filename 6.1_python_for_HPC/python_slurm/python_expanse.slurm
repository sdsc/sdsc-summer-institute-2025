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

# Set local SSD scratch
export LOCAL_SCRATCH_DIR=$SLURM_TMPDIR

echo "🔧 Running on nodes:"
scontrol show hostname $SLURM_NODELIST

srun --exact --ntasks=3 --ntasks-per-node=1 bash -c 'source ./stage_condaenv.sh pythonhpc && python node_info.py'
