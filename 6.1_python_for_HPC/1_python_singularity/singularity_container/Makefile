img = dask-numba-si24.sif
recipe = Singularity.anaconda3-dask-numba

build: ${recipe} clean
	sudo singularity build ${img} ${recipe}

clean:
	sudo rm -f ${img}

copy: ${img}
	scp ${img} login.expanse.sdsc.edu:/expanse/lustre/projects/sds166/zonca/
