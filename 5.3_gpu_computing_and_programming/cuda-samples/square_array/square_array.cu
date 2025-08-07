// UCSD Phys244
// Spring 2021
// Andreas Goetz (agoetz@sdsc.edu)

// CUDA program to square matrix elements in parallel on the GPU
//

#include<stdio.h>

// define matrix size, number of blocks NBL and threads per block TPB
#define NROW 32768
#define NCOL 16384
#define NBLX 32
#define NBLY 32
#define TPBX 16
#define TPBY 16

//
// CUDA device function that squares elements of a 2D array
//
__global__ void square(long int *arr, size_t maxrow, size_t maxcol){

  size_t rowinit = threadIdx.x + blockDim.x * blockIdx.x;
  size_t colinit = threadIdx.y + blockDim.y * blockIdx.y;
  size_t rowstride = gridDim.x * blockDim.x;
  size_t colstride = gridDim.y * blockDim.y;
  size_t pos;

  // operate on all submatrices
  for (size_t row = rowinit; row < maxrow; row += rowstride) {
    for (size_t col = colinit; col < maxcol; col += colstride) {
      pos = row*maxcol + col;
      arr[pos] *= arr[pos];
    }
  }

}

//
// main program
//
int main(void){

  long int h_a[NROW][NCOL];
  long int *d_a;
  size_t size = NROW * NCOL * sizeof(long int);
  int err;

  // allocate device memory
  cudaMalloc((void **)&d_a, size);

  // initialize matrix
  for (size_t i=0; i<NROW; i++){
    for (size_t j=0; j<NCOL; j++){
      h_a[i][j] = i+j;
      // printf("Element (%d,%d) = %d\n",i,j,h_a[i][j]);
    }
  }

  // copy input data to device
  cudaMemcpy(d_a, h_a, size, cudaMemcpyHostToDevice);

  // add vectors by launching a sufficient number of blocks of the add() kernel
  printf("\nLaunching kernel to square matrix elements...\n");
  printf("Matrix elements   = %d x %d = %d\n",NROW,NCOL,NROW*NCOL);
  printf("Blocks            = %d x %d = %d\n",NBLX,NBLY,NBLX*NBLY);
  printf("Threads per block = %d x %d = %d\n",TPBX,TPBY,TPBX*TPBY);
  printf("Kernel copies     = %d\n",NBLX*NBLY*TPBX*TPBY);
  square<<<dim3(NBLX,NBLY),dim3(TPBX,TPBY)>>>(d_a, NROW, NCOL);

  // copy results back to host
  cudaMemcpy(h_a, d_a, size, cudaMemcpyDeviceToHost);

  // deallocate memory
  cudaFree(d_a);

  // check results
  err = 0;
  for (size_t i=0; i<NROW; i++){
    for (size_t j=0; j<NCOL; j++){
      if (h_a[i][j] != (i+j)*(i+j)) err += 1;
      //printf("Element (%d,%d) = %d\n",i,j,h_a[i][j]);
    }
  }
  if (err != 0){
    printf("\n Error, %d elements do not match!\n\n", err);
  } else {
    printf("\n Success! All elements match.\n\n");
  }

  return 0;

}
