import os
import socket
import psutil

hostname = socket.gethostname()
total_memory_gb = psutil.virtual_memory().total / (1024 ** 3)
num_cores = psutil.cpu_count(logical=True)
conda_prefix = os.environ.get("CONDA_PREFIX", "N/A")
slurm_procid = os.environ.get("SLURM_PROCID", "N/A")
slurm_localid = os.environ.get("SLURM_LOCALID", "N/A")
slurm_nodeid = os.environ.get("SLURM_NODEID", "N/A")

def log(msg):
    print(f"[{hostname} | rank={slurm_procid}] {msg}", flush=True)

log(f"Memory: {total_memory_gb:.2f} GB")
log(f"Logical cores: {num_cores}")
log(f"Conda environment path: {conda_prefix}")
log(f"SLURM_LOCALID={slurm_localid}, SLURM_NODEID={slurm_nodeid}")
