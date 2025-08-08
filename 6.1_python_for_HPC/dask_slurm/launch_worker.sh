echo "Launching dask worker"
MEM_GB=240
# memory limit is in bytes
MEM=$(( $MEM_GB*1024**3 ))
dask worker --scheduler-file ~/.dask_scheduler.json --memory-limit $MEM --nworkers 1 --nthreads 128
