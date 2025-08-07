echo "Launching dask scheduler"
echo "Make sure you are executing this on the node running Jupyter Notebook"
PUBLIC_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
LOCAL_IP=$(hostname -I | cut -d' ' -f1)
dask scheduler --scheduler-file ~/.dask_scheduler.json --host $PUBLIC_IP
