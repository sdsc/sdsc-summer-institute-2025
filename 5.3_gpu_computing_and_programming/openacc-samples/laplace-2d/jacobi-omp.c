/*
 *  Copyright 2013 NVIDIA Corporation
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

#include <math.h>
#include <string.h>
#include <omp.h>
#include <stdio.h>
#include "timer.h"

#define NN 256
#define NM 256

double A[NN][NM];
double Anew[NN][NM];

int main(int argc, char** argv)
{
    const int n = NN;
    const int m = NM;
    const int iter_max = 1000;
    
    const double tol = 1.0e-6;
    double error     = 1;
    double terr      = 1;
    
    int nthreads, tid;
    
    memset(A, 0, n * m * sizeof(double));
    memset(Anew, 0, n * m * sizeof(double));

#pragma omp parallel private (nthreads, tid)
    {
        /* Obtain thread number */
        tid = omp_get_thread_num();
    
        /* Only master thread does this */
        if (tid == 0) 
        {
            nthreads = omp_get_num_threads();
	    printf("Number of threads = %d\n", nthreads);
        }
    }

    for (int j = 0; j < n; j++)
    {
        A[j][0]    = 1.0;
        Anew[j][0] = 1.0;
    }
    
    printf("Jacobi relaxation Calculation: %d x %d mesh\n", n, m);
    
    StartTimer();
    int iter = 0;

/* create parallel region */
#pragma omp parallel shared(Anew, A)
    while ( error > tol && iter < iter_max )
    {

/* variable error is shared
   make sure all threads enter while loop before setting to zero  */
#pragma omp barrier      
	error = 0;

/* we need to find the max error among all threads
   use reduction operator to implicitly create local variable
   and do a max reduction at end of loop */
#pragma omp for reduction(max:error)
        for( int j = 1; j < n-1; j++)
        {
            for( int i = 1; i < m-1; i++ )
            {
                Anew[j][i] = 0.25 * ( A[j][i+1] + A[j][i-1]
                                    + A[j-1][i] + A[j+1][i]);
		error = fmax( error, fabs(Anew[j][i] - A[j][i]));
            }
        }

/* there is an implicit barrier after 'omp for'
   so we do not need a barrier here
   (to ensure that all threads finished setting Anew) */
#pragma omp for
        for( int j = 1; j < n-1; j++)
        {
            for( int i = 1; i < m-1; i++ )
            {
                A[j][i] = Anew[j][i];    
            }
        }

/* we want to print and update the global iteration counter
   once (by a single thread) */
#pragma omp single	
      {
        if(iter % 100 == 0) printf("%5d, %0.6f\n", iter, error);
        iter++;
      }
    }

    double runtime = GetTimer();
 
    printf(" total: %f s\n", runtime / 1000);
}
