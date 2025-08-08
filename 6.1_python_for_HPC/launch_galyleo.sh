# Use current folder
NOTEBOOK_FOLDER=$(pwd -P)
## Create link
#cd 1_dask_tutorial
#rm -f data
#ln -s /expanse/lustre/projects/sds166/zonca/dask_tutorial_data data
#cd ../

galyleo launch \
  --account ${SI25_ACCOUNT} \
  --partition compute \
  --cpus 128 \
  --memory 242 \
  --time-limit 04:00:00 \
  --conda-yml environment.yaml \
  --notebook-dir ${NOTEBOOK_FOLDER} \
  --reservation ${SI25_RES_CPU} \
  --cache \
  --quiet
