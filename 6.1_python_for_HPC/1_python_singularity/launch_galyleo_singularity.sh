galyleo launch \
  --account ${SI25_ACCOUNT} \
  --partition shared \
  --cpus 4 \
  --memory 16 \
  --time-limit 00:30:00 \
  --env-modules singularitypro \
  --sif /expanse/lustre/scratch/$USER/temp_project/datascience-notebook_latest.sif \
  --bind /expanse,/scratch \
  --quiet
