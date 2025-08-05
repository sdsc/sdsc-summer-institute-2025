# High Throughput Computing

- [Parallel paradigms: HPC vs. HTC](PARALLEL.md)
- [Batch job arrays](ARRAYS.md)
- [Batch job dependencies](DEPENDENCIES.md)
- [Batch job bundling](BUNDLING.md)
- [Preemptible batch jobs](PREEMPTIBLE.md)
- [Distributed high-throughput computing](DHTC.md)

## Batch job bundling

While Expanse was designed to be supportive of HTC-like workflows, most HPC systems are built to accomodate large-scale, parallel jobs. On these systems, compute resources are often scheduled at the node-level and they either discourage or explicitly prohibit the queueing hundreds or thousands of jobs at a time in order to improve the scheduling performance of the system. Under these circumstances, the only way to run HTC workflows that consist of many serial (or small multi-core) jobs without being inherently wasteful and inefficient is to create *job bundles*, wherein a group of independent jobs or tasks are *packed* into and managed (usually in an ad-hoc way) by a single batch job. 

### Linux-native scheduling

#### `&`

The simplest and most straightforward approach to bundling jobs is with the [Linux scheduler](https://en.wikipedia.org/wiki/Completely_Fair_Scheduler). When you execute a command in a batch job script, you can force the process that is started into the *background* to run independently of other processes that may also be created as part of the job. The Linux scheduler will (automagically) distribute the (child) processes across the compute resources available to run the job. 

```
#!/usr/bin/env bash

#SBATCH --job-name=estimate-pi
#SBATCH --account=gue998
#SBATCH --reservation=si25cpu
#SBATCH --partition=shared
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=00:30:00
#SBATCH --output=%x.o%j.%N

module purge

python3 "${HOME}/4pi/python/pi.py" 100000000 &
python3 "${HOME}/4pi/python/pi.py" 100000000 &
python3 "${HOME}/4pi/python/pi.py" 100000000 &
python3 "${HOME}/4pi/python/pi.py" 100000000 &
```

```
wait
```

The Linux scheduler works well for simple workflows like the one above. However, for workflows with a large number of jobs, especially when each job may be running with multiple processes, the performance of the Linux scheduler may be unsatisfying, due to unbalanced workloads from different running jobs, improper process/thread affinity settings, etc.

</br>

#### `taskset` - set or retrieve a process's CPU affinity

`taskset`  is  used  to  set  or  retrieve  the CPU affinity of a running process given its pid, or to launch a new  command  with  a  given  CPU affinity.  CPU affinity is a scheduler property that "binds" a process to a given set of CPUs on the system.  The Linux scheduler  will  honor the  given CPU affinity and the process will not run on any other CPUs.

```
#SBATCH --output=%x.o%j.%N

module purge

taskset -c 0 python3 "${HOME}/4pi/python/pi.py" 100000000 &
taskset -c 1 python3 "${HOME}/4pi/python/pi.py" 100000000 &
taskset -c 2 python3 "${HOME}/4pi/python/pi.py" 100000000 &
taskset -c 3 python3 "${HOME}/4pi/python/pi.py" 100000000 &

time -p wait
```

```
taskset: taskset: failed to set pid 1239682's affinity: failed to set pid 1239683's affinity: Invalid argument
Invalid argument
taskset: taskset: failed to set pid 1239685's affinity: failed to set pid 1239684's affinity: Invalid argument
Invalid argument
```

What went wrong? Are you the only person running on this node?

```
squeue -u $USER
```

```
[xdtr108@login01 ~]$ squeue --nodelist=exp-14-54
```

```
[xdtr108@exp-14-54 ~]$ lscpu
Architecture:        x86_64
CPU op-mode(s):      32-bit, 64-bit
Byte Order:          Little Endian
CPU(s):              128
On-line CPU(s) list: 0-127
Thread(s) per core:  1
Core(s) per socket:  64
Socket(s):           2
NUMA node(s):        8
Vendor ID:           AuthenticAMD
CPU family:          23
Model:               49
Model name:          AMD EPYC 7742 64-Core Processor
Stepping:            0
CPU MHz:             3392.265
BogoMIPS:            4491.75
Virtualization:      AMD-V
L1d cache:           32K
L1i cache:           32K
L2 cache:            512K
L3 cache:            16384K
NUMA node0 CPU(s):   0-15
NUMA node1 CPU(s):   16-31
NUMA node2 CPU(s):   32-47
NUMA node3 CPU(s):   48-63
NUMA node4 CPU(s):   64-79
NUMA node5 CPU(s):   80-95
NUMA node6 CPU(s):   96-111
NUMA node7 CPU(s):   112-127
Flags:               fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext fxsr_opt pdpe1gb rdtscp lm constant_tsc rep_good nopl nonstop_tsc cpuid extd_apicid aperfmperf pni pclmulqdq monitor ssse3 fma cx16 sse4_1 sse4_2 x2apic movbe popcnt aes xsave avx f16c rdrand lahf_lm cmp_legacy svm extapic cr8_legacy abm sse4a misalignsse 3dnowprefetch osvw ibs skinit wdt tce topoext perfctr_core perfctr_nb bpext perfctr_llc mwaitx cpb cat_l3 cdp_l3 hw_pstate ssbd mba ibrs ibpb stibp vmmcall fsgsbase bmi1 avx2 smep bmi2 cqm rdt_a rdseed adx smap clflushopt clwb sha_ni xsaveopt xsavec xgetbv1 xsaves cqm_llc cqm_occup_llc cqm_mbm_total cqm_mbm_local clzero irperf xsaveerptr wbnoinvd amd_ppin arat npt lbrv svm_lock nrip_save tsc_scale vmcb_clean flushbyasid decodeassists pausefilter pfthreshold avic v_vmsave_vmload vgif v_spec_ctrl umip rdpid overflow_recov succor smca sme sev sev_es
```

Let's go ahead and move the job from the **shared** to the **compute** partition.

```
#SBATCH --partition=compute
#SBATCH --qos=normal-eot
```

```
[xdtr108@login01 ~]$ sbatch estimate-pi.sh 
Submitted batch job 14843082
[xdtr108@login01 ~]$ squeue -u $USER
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          14843082   compute estimate  xdtr108  R       0:04      1 exp-14-54
[xdtr108@login01 ~]$ ssh exp-14-54
Last login: Tue Aug  2 09:28:42 2022 from 10.21.0.19
[xdtr108@exp-14-54 ~]$ htop -u $USER
```

```
#!/usr/bin/env bash

#SBATCH --job-name=estimate-pi
#SBATCH --account=crl155
#SBATCH --reservation=SI2022DAY2
#SBATCH --partition=compute
#SBATCH --qos=normal-eot
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=128
#SBATCH --cpus-per-task=1
#SBATCH --mem=243G
#SBATCH --time=00:30:00
#SBATCH --output=%x.o%j.%N

module purge

taskset -c 0 python3 "${HOME}/4pi/python/pi.py" 100000000 &
taskset -c 32 python3 "${HOME}/4pi/python/pi.py" 100000000 &
taskset -c 64 python3 "${HOME}/4pi/python/pi.py" 100000000 &
taskset -c 96 python3 "${HOME}/4pi/python/pi.py" 100000000 &

time -p wait
```

Okay, let's now try bundling some multithreaded jobs. First, compile the 4pi fortran programs. 

```
[xdtr108@login02 ~]$ cd 4pi/fortran/
[xdtr108@login02 fortran]$ ls
Makefile  pi.f90  pi_omp.f90
[xdtr108@login02 fortran]$ make
gfortran -ffree-form -ffree-line-length-none -fimplicit-none -O3 -mtune=native -fdefault-integer-8 -fdefault-real-8 -c pi.f90
pi.f90:4:23:

       use, intrinsic :: iso_fortran_env
                       1
Warning: Use of the NUMERIC_STORAGE_SIZE named constant from intrinsic module ISO_FORTRAN_ENV at (1) is incompatible with option -fdefault-integer-8
gfortran -ffree-form -ffree-line-length-none -fimplicit-none -O3 -mtune=native -fdefault-integer-8 -fdefault-real-8 -o pi.x pi.o
gfortran -ffree-form -ffree-line-length-none -fimplicit-none -O3 -mtune=native -fdefault-integer-8 -fdefault-real-8 -fopenmp -c pi_omp.f90
pi_omp.f90:4:23:

       use, intrinsic :: iso_fortran_env
                       1
Warning: Use of the NUMERIC_STORAGE_SIZE named constant from intrinsic module ISO_FORTRAN_ENV at (1) is incompatible with option -fdefault-integer-8
gfortran -ffree-form -ffree-line-length-none -fimplicit-none -O3 -mtune=native -fdefault-integer-8 -fdefault-real-8 -fopenmp -o pi_omp.x pi_omp.o
[xdtr108@login02 fortran]$ ls
Makefile  pi.f90  pi.o  pi_omp.f90  pi_omp.o  pi_omp.x  pi.x
[xdtr108@login02 fortran]$ cd ~/
[xdtr108@login02 ~]$
```

Then we'll replace our 4pi python program with the OpenMP parallelized fortran program `pi_omp.x`. 

```
#!/usr/bin/env bash

#SBATCH --job-name=estimate-pi
#SBATCH --account=crl155
#SBATCH --reservation=SI2022DAY2
#SBATCH --partition=compute
#SBATCH --qos=normal-eot
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=128
#SBATCH --cpus-per-task=1
#SBATCH --mem=243G
#SBATCH --time=00:30:00
#SBATCH --output=%x.o%j.%N

module purge
export PATH="${HOME}/4pi/fortran:${PATH}"
export OMP_NUM_THREADS=1

taskset -c 0 pi_omp.x -s 10000000000 &
taskset -c 32 pi_omp.x -s 10000000000 &
taskset -c 64 pi_omp.x -s 10000000000 &
taskset -c 96 pi_omp.x -s 10000000000 &

time -p wait
```

https://hexus.net/tech/reviews/cpu/133244-amd-epyc-7742-2p-rome-server


```
export OMP_NUM_THREADS=4

taskset -c 0,1,2,3 pi_omp.x -s 10000000000 &
taskset -c 32,33,34,35 pi_omp.x -s 10000000000 &
taskset -c 64,65,66,67 pi_omp.x -s 10000000000 &
taskset -c 96,97,98,99 pi_omp.x -s 10000000000 &

time -p wait
```

</br>

#### `numactl` - Control NUMA policy for processes or shared memory

`numactl` runs processes with a specific NUMA scheduling or memory placement policy.  The policy is set for a command and is inherited by all of its children.  In addition it can set persistent policy for shared memory segments or files.

```
[xdtr108@exp-14-54 ~]$ numactl -H
available: 8 nodes (0-7)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
node 0 size: 31799 MB
node 0 free: 29298 MB
node 1 cpus: 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
node 1 size: 32251 MB
node 1 free: 29869 MB
node 2 cpus: 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47
node 2 size: 32251 MB
node 2 free: 30542 MB
node 3 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63
node 3 size: 32239 MB
node 3 free: 29492 MB
node 4 cpus: 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79
node 4 size: 32251 MB
node 4 free: 31592 MB
node 5 cpus: 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95
node 5 size: 32213 MB
node 5 free: 31495 MB
node 6 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111
node 6 size: 32251 MB
node 6 free: 31518 MB
node 7 cpus: 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127
node 7 size: 32250 MB
node 7 free: 31160 MB
node distances:
node   0   1   2   3   4   5   6   7 
  0:  10  12  12  12  32  32  32  32 
  1:  12  10  12  12  32  32  32  32 
  2:  12  12  10  12  32  32  32  32 
  3:  12  12  12  10  32  32  32  32 
  4:  32  32  32  32  10  12  12  12 
  5:  32  32  32  32  12  10  12  12 
  6:  32  32  32  32  12  12  10  12 
  7:  32  32  32  32  12  12  12  10 
[xdtr108@exp-14-54 ~]$ 
```

- https://cvw.cac.cornell.edu/hybrid/numactl
- https://www.glennklockwood.com/hpc-howtos/process-affinity.html
- https://dl.acm.org/doi/fullHtml/10.1145/3437359.3465569

### GNU parallel

- https://en.wikipedia.org/wiki/GNU_parallel

### MPI-based scheduling

```
#!/usr/bin/env bash

#SBATCH --job-name=estimate-pi
#SBATCH --account=crl155
#SBATCH --reservation=SI2022DAY2
#SBATCH --partition=compute
#SBATCH --qos=normal-eot
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=4
#SBATCH --mem=243G
#SBATCH --time=00:30:00
#SBATCH --output=%x.o%j.%N

module reset
module load gcc
module load openmpi
export PATH="${HOME}/4pi/fortran:${PATH}"
export OMP_NUM_THREADS=4

time -p srun --mpi=pmi2 pi_omp.x -s 10000000000
```

Now try going multinode!

```
#SBATCH --nodes=2
```

### Advanced job bundling tools and utilities

Many HPC centers have also developed their own custom job bundling tools to provide more advanced capabilties than the methods discuess thus far. In general, you can use these bundling utilties on other systems. However, they may take some time to setup and deploy on a new system. For example, one popular job bundling tool is the [Texas Advanced Computing Center (TACC) launcher](https://github.com/TACC/launcher), which has been used at SDSC in the past and is also available on [Georgia Tech's PACE cluster](https://docs.pace.gatech.edu/software/launcher). Other examples of job bundling tools and utilities include [NCSA's scheduler.x](https://github.com/ncsa/Scheduler) and [NIH's Swarm](https://hpc.nih.gov/apps/swarm.html).

#

Next - [Preemptible batch jobs](PREEMPTIBLE.md)
