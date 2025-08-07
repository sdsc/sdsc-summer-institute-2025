# Using Singularity to run a Docker container on Expanse

This guide explains how to pull the `jupyter/datascience-notebook` container from Docker Hub using Singularity on SDSC Expanse, and then how to launch it using Galyleo.

## 1. Launch an Interactive Debug Job

Use `srun` to get access to a compute node with local SSD for a temporary build environment, during the Summer Institute:

```bash
srun-compute
```

afterwards:

```bash
srun \
  --partition=debug \
  --nodes=1 \
  --ntasks=1 \
  --cpus-per-task=4 \
  --mem=8G \
  --time=00:30:00 \
  --pty bash
```

## 2. Load SingularityPro

```bash
module load singularitypro
```

## 3. Set Environment Variables for Singularity

Use the local SSD job space for caching and temporary build files:

```bash
export SINGULARITY_CACHEDIR="$SLURM_TMPDIR/singularity_cache"
export SINGULARITY_TMPDIR="$SLURM_TMPDIR"
mkdir -p "$SINGULARITY_CACHEDIR"
```

## 4. Pull the Docker Image and Save to Lustre Scratch

Use the `temp_project` subdirectory in your Lustre scratch for storing the final `.sif`:

```bash
mkdir -p /expanse/lustre/scratch/$USER/temp_project

singularity pull /expanse/lustre/scratch/$USER/temp_project/datascience-notebook_latest.sif \
    docker://jupyter/datascience-notebook:latest
```

This command converts the Docker image to a Singularity `.sif` file and stores it in your persistent Lustre scratch space.

---

## 5. Launch the Container with Galyleo

You can now launch the `.sif` container using Galyleo:

```bash
bash launch_galyleo_singularity.sh
```

> 📌 Make sure to update the path to your `.sif` file if you stored it in a different subfolder.

This will launch a Jupyter Notebook environment based on the `jupyter/datascience-notebook` container using Galyleo.

---

## Notes

* Avoid building Singularity images on the login node — always use a compute node.
* `$SLURM_TMPDIR` is local SSD on compute nodes and ideal for temporary build/cache use.
* `/expanse/lustre/scratch/$USER/temp_project` is recommended for storing large container files.
* Refer to the official docs at [hpc-training.sdsc.edu/galyleo](https://hpc-training.sdsc.edu/galyleo/) for full CLI options and examples.
