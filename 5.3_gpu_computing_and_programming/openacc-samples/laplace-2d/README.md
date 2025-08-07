# Credit
Mark Harris - NVIDIA Corporation
Andreas Goetz - SDSC: OMP code and minor modifications

# Description
A simple Jacobi iteration useful for teaching both the kerenels (or parallel) 
and data directives. There is some high-level timing code built-in to the 
program, but you may wish to also make use of a profiler when using this
example.

# Files

Miscellaneous:
`timer.h` - simple timing code

Exercise:
`jacobi.c`   - The serial C code lacking any OpenACC constructs  
`jacobi.f90` - The serial Fortran code lacking any OpenACC constructs  

`jacobi-omp.c`   - OpenMP parallel C code  
`jacobi-omp.f90` - OpenMP parallel Fortran code

Solution:
`jacobi-acc.c` - A simple OpenACC C ccelerated version of the code.
`jacobi-acc.f90` - A simple OpenACC Fortran accelerated version of the code.

Compile:
Using the PGI compiler

    # CPU serial version
    pgcc -fast -o jacobi-pgcc.x jacobi.c
    pgf90 -fast -o jacobi-pgf90.x jacobi.f90

    # CPU OpenMP parallel version
    pgcc -fast -mp -Minfo=mp -o jacobi-pgcc-omp.x jacobi-omp.c
    pgf90 -fast -mp -Minfo=mp -o jacobi-pgf90-omp.x jacobi-omp.f90

    # GPU OpenACC version
    pgcc -acc -Minfo=accel -o jacobi-pgcc-acc.x jacobi-acc.c
    pgf90 -acc -Minfo=accel -o jacobi-pgf90-acc.x jacobi-acc.f90

