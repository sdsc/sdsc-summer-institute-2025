// UCSD Phys244
// Spring 2021
// Andreas Goetz (agoetz@sdsc.edu)

// Hello World Program in CUDA C
//
// Contains a function that is executed on the device (GPU)
// Note that printf statements also work on the GPU
// We are using CUDA variables blockIdx.x and threadIdx.x
// These are unique indices for each thread that is executing on the GPU
// With <<<2,2>>> we launch 2 x 4 = 8 threads (4 threads per block)
//

#include <stdio.h>

__global__ void my_kernel(void)
{
  printf("Hello World from GPU! I am thread [%d,%d]\n", blockIdx.x, threadIdx.x);
}

int main(void) {

  my_kernel<<<2,4>>>();
  cudaDeviceSynchronize();
  printf("Hello World from CPU!\n");
  return 0;

}
