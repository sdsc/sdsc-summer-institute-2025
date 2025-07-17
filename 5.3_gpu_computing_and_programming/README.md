### SDSC Summer Institute 2025
# Session 5.2 Performance Tuning

**Date:** Thursday, August 7

**Summary**: This session introduces massively parallel computing with graphics processing units (GPUs). The use of GPUs is popular across all scientific domains since GPUs can significantly accelerate time to solution for many computational tasks. Participants will be introduced to essential background of the GPU chip architecture and will learn how to program GPUs via the use of libraries, OpenACC compiler directives, and CUDA programming. The session will incorporate hands-on exercises for participants to acquire the basic skills to use and develop GPU aware applications.

**Presented by:** [Andreas Goetz](https://www.sdsc.edu/research/researcher_spotlight/goetz_andreas.html) (awgoetz @ucsd.edu)

**Presentation Slides**: [GPU Computing and Programming](<GPU Computing SI2024.pdf>)

**Source code**:
* [Official Nvidia CUDA samples](https://github.com/NVIDIA/cuda-samples)
* [CUDA examples from slides](cuda-samples)
* [OpenACC examples from slides](openacc-samples)

## Accessing GPU nodes and running GPU jobs on SDSC Expanse:

We will log into an Expanse GPU node, compile and test some examples from the Nvidia CUDA samples.

### Log into Expanse, get onto a shared GPU node, and load required modules

First, log onto Expanse using your `etrainXX` training account. You can do this either via the Expanse user portal or simply using ssh:
```
ssh etrainXX@login.expanse.sdsc.edu
```

Next we will use the alias for the `srun` command that is defined in your `.bashrc` file to access a single GPU on a shared GPU node:
```
srun-gpu-shared
```

Once we are on a GPU node, we load the `gpu` module to gain access to the GPU software stack. We will also load the `cuda12.2/toolkit` module, which provides the CUDA Toolkit:
```
module reset  # this will load the gpu module when on GPU nodes
module load cuda12.2/toolkit
module list
```
You should see following output
```

Currently Loaded Modules:
  1) shared            3) slurm/expanse/23.02.7   5) DefaultModules
  2) gpu/0.17.3b (g)   4) sdsc/1.0

  Where:
   g:  built natively for Intel Skylake
```

We can use the `nvidia-smi` command to check for available GPUs and which processes are running on the GPU.
```
nvidia-smi
```
You should have a single V100 GPU available and there should be no processes running:
```
Mon Jun 27 08:39:33 2022       
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 510.39.01    Driver Version: 510.39.01    CUDA Version: 11.6     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  Tesla V100-SXM2...  On   | 00000000:18:00.0 Off |                    0 |
| N/A   39C    P0    41W / 300W |      0MiB / 32768MiB |      0%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
```

## Hands-on exercises on SDSC Expanse – CUDA

This Github repository contains the CUDA examples that were discussed during the presentation (directory `cuda-samples`).

If you are interested in additional CUDA samples, take a look at the [official Nvidia CUDA samples Github repository](https://github.com/NVIDIA/cuda-samples). The Nvidia CUDA samples are also available in the `etrainXX` home directory under `~/data/cuda-samples-v12.2.tar.gz`.

We recommend to extract the tarball in the local scratch directory:
```
cd $SLURM_TMPDIR
tar xvf ~/data/cuda-samples-v12.2.tar.gz
```

We are now ready to look at the Nvidia CUDA samples.
It can be instructive to look at the source code if you want to learn about CUDA.


### Compile and run the `deviceQuery` CUDA sample

The first sample we will look at is `device_query`. This is a utility that demonstrates how to query Nvidia GPU properties. It often comes in handy to check information on the GPU that you have available.

First, we check that we have an appropriate NVIDIA CUDA compiler available. The CUDA samples require at least version 11.6. Because we loaded the `nvhpc` module above, we should have the `nvcc` compiler available:
```
nvcc --version
```
should give the following output
```
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2023 NVIDIA Corporation
Built on Tue_Aug_15_22:02:13_PDT_2023
Cuda compilation tools, release 12.2, V12.2.140
Build cuda_12.2.r12.2/compiler.33191640_0
```

We have version 12.2 installed so we are good to go. 

We can now move into the `device_query` source directory and compile the code with the `make` command. By default the Makefile will compile for all possible Nvidia GPU architectures. We restrict it to use SM version 7.0, which is the architecture of the V100 GPUs in Expanse (although we could just compile all as well):
```
cd cuda-samples-12.2/Samples/1_Utilities/deviceQuery
```
```
make SMS=70
```

You now should have an executable `deviceQuery` in the directory. If you execute it: 
```
./deviceQuery
```
you should see an output with details about the GPU that is available. In our case on Expanse it is a Tesla V100-SXM2-32GB GPU:
```
./deviceQuery Starting...

 CUDA Device Query (Runtime API) version (CUDART static linking)

Detected 1 CUDA Capable device(s)

Device 0: "Tesla V100-SXM2-32GB"
  CUDA Driver Version / Runtime Version          11.6 / 11.2
  CUDA Capability Major/Minor version number:    7.0
  Total amount of global memory:                 32511 MBytes (34089926656 bytes)
  (080) Multiprocessors, (064) CUDA Cores/MP:    5120 CUDA Cores
  GPU Max Clock rate:                            1530 MHz (1.53 GHz)
  Memory Clock rate:                             877 Mhz
  Memory Bus Width:                              4096-bit
  L2 Cache Size:                                 6291456 bytes
  Maximum Texture Dimension Size (x,y,z)         1D=(131072), 2D=(131072, 65536), 3D=(16384, 16384, 16384)
  Maximum Layered 1D Texture Size, (num) layers  1D=(32768), 2048 layers
  Maximum Layered 2D Texture Size, (num) layers  2D=(32768, 32768), 2048 layers
  Total amount of constant memory:               65536 bytes
  Total amount of shared memory per block:       49152 bytes
  Total shared memory per multiprocessor:        98304 bytes
  Total number of registers available per block: 65536
  Warp size:                                     32
  Maximum number of threads per multiprocessor:  2048
  Maximum number of threads per block:           1024
  Max dimension size of a thread block (x,y,z): (1024, 1024, 64)
  Max dimension size of a grid size    (x,y,z): (2147483647, 65535, 65535)
  Maximum memory pitch:                          2147483647 bytes
  Texture alignment:                             512 bytes
  Concurrent copy and kernel execution:          Yes with 5 copy engine(s)
  Run time limit on kernels:                     No
  Integrated GPU sharing Host Memory:            No
  Support host page-locked memory mapping:       Yes
  Alignment requirement for Surfaces:            Yes
  Device has ECC support:                        Enabled
  Device supports Unified Addressing (UVA):      Yes
  Device supports Managed Memory:                Yes
  Device supports Compute Preemption:            Yes
  Supports Cooperative Kernel Launch:            Yes
  Supports MultiDevice Co-op Kernel Launch:      Yes
  Compute Mode:
     < Default (multiple host threads can use ::cudaSetDevice() with device simultaneously) >

deviceQuery, CUDA Driver = CUDART, CUDA Driver Version = 11.6, CUDA Runtime Version = 11.2, NumDevs = 1
Result = PASS
```

### Compile and run the matrix multiplication

It is instructive to look at two different matrix multiplication examples and compare the performance.

First we will look at a hand-written matrix multiplication. This implementation features several performance optimizations such as minimize data transfer from GPU RAM to the GPU processors and increase floating point performance.
```
cd $SLURM_TMPDIR
cd cuda-samples-12.2/Samples/0_Introduction/matrixMul
```
```
make SMS=70
```
We now have the executable `matrixMul` available. If we execute it,
```
./matrixMul
```
a matrix multiplication will be performed and the performance reported
```
[Matrix Multiply Using CUDA] - Starting...
GPU Device 0: "Volta" with compute capability 7.0

MatrixA(320,320), MatrixB(640,320)
Computing result using CUDA Kernel...
done
Performance= 2796.59 GFlop/s, Time= 0.047 msec, Size= 131072000 Ops, WorkgroupSize= 1024 threads/block
Checking computed result for correctness: Result = PASS

NOTE: The CUDA Samples are not meant for performance measurements. Results may vary when GPU Boost is enabled.
```

### Compile and run matrix multiplication with CUBLAS library

Finally, let us look at a matrix multiplication that uses Nvidia's CUBLAS library, which is a highly optimized version of the Basic Linear Algebra System for Nvidia GPUs.

We are now ready to compile the example:
```
cd $SLURM_TMPDIR
cd cuda-samples-12.2/Samples/4_CUDA_Libraries/matrixMulCUBLAS
```
```
make SMS=70
```
If we run the executable
```
./matrixMulCUBLAS
```
we should get following output:
```
[Matrix Multiply CUBLAS] - Starting...
GPU Device 0: "Volta" with compute capability 7.0

GPU Device 0: "Tesla V100-SXM2-32GB" with compute capability 7.0

MatrixA(640,480), MatrixB(480,320), MatrixC(640,320)
Computing result using CUBLAS...done.
Performance= 7032.97 GFlop/s, Time= 0.028 msec, Size= 196608000 Ops
Computing result using host CPU...done.
Comparing CUBLAS Matrix Multiply with CPU results: PASS

NOTE: The CUDA Samples are not meant for performance measurements. Results may vary when GPU Boost is enabled.
```

How does the performance compare to the hand written (but optimized) matrix multiplication?


### CUDA samples from slides

Now take a look at the directory `cuda-samples` in the SI2024 Github repository, which contains the examples that were discussed during the presentation.


## Hands-on exercises on SDSC Expanse – OpenACC

This Github repository also contains the OpenACC examples that were discussed during the presentation (directory `openacc-samples`).

First, load the NVHPC SDK. Make sure to unload the CUDA Toolkit if it is loaded. We can do this by resetting the environment.
```
module reset
module load nvhpc/21.9
```

You should now have the NVHPC (formerly PGI) compiler available. In all examples below you can replace `pgcc` with `nvc` and `pgf90` with `nvfortran`. We can check for example for the version of the PGI C compiler
```
pgcc --version
```
which should give the following output
```
pgcc (aka nvc) 21.9-0 64-bit target on x86-64 Linux -tp skylake 
PGI Compilers and Tools
Copyright (c) 2021, NVIDIA CORPORATION & AFFILIATES.  All rights reserved.
```


### `saxpy` OpenACC sample

This example contains the C program `saxpy.c` that performs a single precision vector addition (y = a*x + y). It can be compiled with standard C compiler or PGI pgcc compiler with accelerator directives.
```
pgcc saxpy.c -o saxpy-cpu.x
pgcc saxpy.c -acc -Minfo=accel -o saxpy-gpu.x
```

Compile and run the codes for CPU and GPU.


### Jacobi solver of 2D Laplace equation,  OpenACC sample

See subdirectory `laplace-2d`, which contains C and Fortran versions of a Jacobi solver for 2D Laplace equation including OpenMP and OpenACC versions.

Compile the serial CPU code, the OpenMP parallelized CPU code, and the OpenACC GPU accelerated version of the code:
```
# Serial Fortran code
pgf90 jacobi.f90 -fast -o jacobi-pgf90.x

# Serial C code
pgcc jacobi.c -fast -o jacobi-pgcc.x 

# OpenMP parallel Fortran code
pgf90 jacobi-omp.f90 -fast -mp -Minfo=mp -o jacobi-pgf90-omp.x 

# OpenMP parallel C code
pgcc jacobi-omp.c -fast -mp -Minfo=mp -o jacobi-pgcc-omp.x 

# OpenACC Fortran version
pgf90 jacobi-acc.f90 -acc -Minfo=accel -o jacobi-pgf90-acc.x 

# OpenACC C version
pgcc jacobi-acc.c -acc -Minfo=accel -o jacobi-pgcc-acc.x
```

Now benchmark the different versions. In order to use multiple cores with OpenACC, you need to set the corresponding environment variable:
```
# Example: Use 10 CPU cores with OpenMP Fortran version
export OMP_NUM_THREADS=10
./jacobi-pgf90-omp.x
```

In order to compute on the GPU code, just run the GPU executable:
```
# Example: Use GPU with OpenACC C version
./jacobi-pgcc-acc.x
```

Compare the timings. How much faster is a single V100 GPU than 10 CPU cores?



[Back to Top](#top)
