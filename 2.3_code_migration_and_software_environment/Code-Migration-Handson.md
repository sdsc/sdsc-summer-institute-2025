### Command Set #1 ###
<br>
Lets start with using module commands to search for the MATLAB software available. We can then check which environment variables are changed when one of these modules is loaded.

```
module spider matlab
module show matlab/2022b
```

<br>
Next we look for the ADIOS2 IO library and check for the dependencies that are needed to be loaded and the check the module dependencies that are automatically loaded.

```
module spider adios2
module reset
module load cpu/0.17.3b  gcc/10.2.0/npcyll4  openmpi/4.1.3/oq3qvsv
module load adios2/2.7.1
module list
module show adios2/2.7.1
```

### Command Set #2 ###
<br>
In this part of the hands on section, we will copy over a PyTorch example from the Expanse examples directory and run it. This example uses a PyTorch Singularity image for the software environment.

```
cp -r /cm/shared/examples/sdsc/pytorch .
cd pytorch
sbatch --res=si25cpu -A gue998 run-pytorch-cpu-shared.sh
```
Once this job runs, check the output file!

### Command Set #3 ###
<br> 
In this example we first get interactive access to a compute node:

```
module reset
srun --pty --reservation=si25cpu --partition=shared --nodes=1 --ntasks-per-node=1 --cpus-per-task=8 --mem=16G -A gue998 -t 00:30:00 --wait 0 /bin/bash
```
Next we set the temporary directory to the node local NVMe scratch directory and change to that directory.

```
export TMPDIR=/scratch/$USER/job_$SLURM_JOBID
cd /scratch/$USER/job_$SLURM_JOBID
```

We next load the Singularity module, and build the Singularity image of the ExceRpt R application based on a docker image.

```
module load singularitypro
singularity build excerpt.sif docker://rkitchen/excerpt
```

Finally we copy over an example input and run the job using Singularity.

```
cp -r /cm/shared/examples/sdsc/excerpt/input .
mkdir output
singularity run --bind ./input:/exceRptInput --bind ./output:/exceRptOutput --bind /expanse/projects/qstore/data/excerpt/hg38:/exceRpt_DB/hg38 --bind /scratch:/scratch /cm/shared/apps/containers/singularity/excerpt/excerpt.sif INPUT_FILE_PATH=/exceRptInput/SRR026761.sra
```

### Command Set #4 ###
<br> 
In our final example we will download the source of the RAxML application and build it using a Makefile. First we set up our MPI compiler environment:

```
module reset
module load gcc/10.2.0
module load openmpi/4.1.3
```

Next we clone the code repository

```
git clone --branch v8.2.13 https://github.com/stamatak/standard-RAxML.git
cd standard-RAxML/
```

Inspect the Makefiles. In particular Makefile.AVX2.MPI.gcc. Then build!

```
make -f Makefile.AVX2.MPI.gcc
```
