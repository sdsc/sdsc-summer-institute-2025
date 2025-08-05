# Use current folder
#NOTEBOOK_FOLDER=$(pwd -P)
## Create link
#cd 1_dask_tutorial
#rm -f data
#ln -s /expanse/lustre/projects/sds166/zonca/dask_tutorial_data data
#cd ../
# Use the user home
# NOTEBOOK_FOLDER=${HOME}

galyleo launch --account ${SI25_ACCOUNT} --reservation ${SI25_RES_CPU} --partition shared --cpus 4 --memory 16 --time-limit 04:00:00 --conda-yml environment.yaml --cache --quiet
