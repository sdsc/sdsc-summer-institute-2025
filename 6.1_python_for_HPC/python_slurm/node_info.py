import os
import socket
import psutil

hostname = socket.gethostname()
total_memory_gb = psutil.virtual_memory().total / (1024 ** 3)
num_cores = psutil.cpu_count(logical=True)
conda_prefix = os.environ.get("CONDA_PREFIX", "N/A")

def log(msg):
    print(f"[{hostname}] {msg}")

log("🔹 Node info")
log(f"Memory: {total_memory_gb:.2f} GB")
log(f"Logical cores: {num_cores}")
log(f"Conda environment path: {conda_prefix}")
