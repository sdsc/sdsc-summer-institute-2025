#!/bin/bash

# Detect if script is being sourced
(return 0 2>/dev/null)
if [[ $? -ne 0 ]]; then
  echo "❌ ERROR: This script must be sourced, not executed."
  echo "ℹ️  Usage: source ${BASH_SOURCE[0]} <conda_env_name>"
  exit 1
fi

# Check for conda env name argument
if [[ -z "$1" ]]; then
  echo "❌ ERROR: Missing conda environment name."
  echo "ℹ️  Usage: source ${BASH_SOURCE[0]} <conda_env_name>"
  return 1
fi

# Take conda env name as input
export conda_env="$1"

# Detect if running interactively
INTERACTIVE=false
if [[ $- == *i* ]]; then
  INTERACTIVE=true
fi

# Helper to print steps with timestamp
log_step() {
  if $INTERACTIVE; then
    echo -e "\n🕒 [$(date '+%Y-%m-%d %H:%M:%S')] $1"
  fi
}

# Start timing
start_time=$(date +%s)

# Save original directory
original_dir=$(pwd)

# Define variables
log_step "Setting environment variables..."
export GALYLEO_CACHE_DIR="${HOME}/.galyleo"
export LOCAL_SCRATCH_DIR=$SLURM_TMPDIR # local SSD on Expanse
export CONDA_INSTALL_PATH="${LOCAL_SCRATCH_DIR}/${USER}_miniforge3"
export CONDA_ENVS_PATH="${CONDA_INSTALL_PATH}/envs"
export CONDA_PKGS_DIRS="${CONDA_INSTALL_PATH}/pkgs"

# Define path for installer
export MINIFORGE_INSTALLER="${LOCAL_SCRATCH_DIR}/Miniforge3-Linux-x86_64.sh"

log_step "Downloading Miniforge installer to local scratch..."
wget -q -O "$MINIFORGE_INSTALLER" \
  https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh

if [[ $? -ne 0 || ! -f "$MINIFORGE_INSTALLER" ]]; then
  echo "❌ ERROR: Failed to download Miniforge installer."
  return 1
fi

log_step "Making Miniforge installer executable..."
chmod +x "$MINIFORGE_INSTALLER"

log_step "Installing Miniforge to ${CONDA_INSTALL_PATH}..."
"$MINIFORGE_INSTALLER" -b -p "$CONDA_INSTALL_PATH" > /dev/null

log_step "Removing Miniforge installer..."
rm -f "$MINIFORGE_INSTALLER"

log_step "Sourcing conda.sh and activating base environment..."
source "${CONDA_INSTALL_PATH}/etc/profile.d/conda.sh"
conda activate base > /dev/null

log_step "Copying cached environment archive from ${GALYLEO_CACHE_DIR}..."
cd "$LOCAL_SCRATCH_DIR"
if [[ ! -f "$GALYLEO_CACHE_DIR/$conda_env/${conda_env}.tar.gz" ]]; then
  echo "❌ ERROR: Cached environment archive not found at $GALYLEO_CACHE_DIR/$conda_env/${conda_env}.tar.gz"
  return 1
fi
cp "$GALYLEO_CACHE_DIR/$conda_env/${conda_env}.tar.gz" ./

log_step "Extracting environment archive..."
mkdir -p "$conda_env"
tar -xf "${conda_env}.tar.gz" -C "$conda_env"

log_step "Activating unpacked environment..."
source "$conda_env/bin/activate"
if command -v conda-unpack &> /dev/null; then
  conda-unpack > /dev/null
else
  if $INTERACTIVE; then
    echo "⚠️  Warning: 'conda-unpack' not found. Skipping."
  fi
fi

# Return to original directory
cd "$original_dir"

# End timing
end_time=$(date +%s)
elapsed=$((end_time - start_time))
log_step "✅ Finished in ${elapsed} seconds."
