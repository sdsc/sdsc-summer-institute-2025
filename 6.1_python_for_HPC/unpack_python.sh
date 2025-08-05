#!/bin/bash

# Detect if script is being sourced
(return 0 2>/dev/null)
if [[ $? -ne 0 ]]; then
  echo "❌ ERROR: This script must be sourced, not executed."
  echo "ℹ️  Usage: source ${BASH_SOURCE[0]}"
  exit 1
fi

# Helper to print steps with timestamp
log_step() {
  echo -e "\n🕒 [$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Start timing
start_time=$(date +%s)

# Define variables
log_step "Setting environment variables..."
export conda_env='pythonhpc'
export GALYLEO_CACHE_DIR="${HOME}/.galyleo"
export LOCAL_SCRATCH_DIR=$SLURM_TMPDIR # local SSD on Expanse
export USERNAME=$(whoami)
export CONDA_INSTALL_PATH="${LOCAL_SCRATCH_DIR}/${USERNAME}_miniforge3"
export CONDA_ENVS_PATH="${CONDA_INSTALL_PATH}/envs"
export CONDA_PKGS_DIRS="${CONDA_INSTALL_PATH}/pkgs"

log_step "Downloading Miniforge installer..."
wget -q https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh

log_step "Making Miniforge installer executable..."
chmod +x Miniforge3-Linux-x86_64.sh

log_step "Installing Miniforge to ${CONDA_INSTALL_PATH}..."
./Miniforge3-Linux-x86_64.sh -b -p "${CONDA_INSTALL_PATH}" > /dev/null

log_step "Sourcing conda.sh and activating base environment..."
source "${CONDA_INSTALL_PATH}/etc/profile.d/conda.sh"
conda activate base > /dev/null

log_step "Copying cached environment archive from ${GALYLEO_CACHE_DIR}..."
cd "$LOCAL_SCRATCH_DIR"
cp "$GALYLEO_CACHE_DIR/$conda_env/${conda_env}.tar.gz" ./

log_step "Extracting environment archive..."
mkdir -p "$conda_env"
tar -xf "${conda_env}.tar.gz" -C "$conda_env"

log_step "Activating unpacked environment..."
source "$conda_env/bin/activate"
conda-unpack > /dev/null

end_time=$(date +%s)
elapsed=$((end_time - start_time))
log_step "✅ Environment setup complete in ${elapsed} seconds."
