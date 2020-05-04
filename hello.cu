#include <stdio.h>
#include <cuda.h>

# define cD2H cudaMemcpyDeviceToHost
# define cH2D cudaMemcpyHostToDevice

# define N 65000
# define NumThreads 1

/*****************************************************/
__global__ void add(int *a, int *b, int *c){

  int tid = blockIdx.x;

  c[tid] = a[tid] + b[tid];

}


/*****************************************************/
int main(){

  int a[N], b[N], c[N];
  int *dev_a, *dev_b, *dev_c;

  for (int i=0; i<N; i++){
    a[i] = -i;
    b[i] = i*i;
  }

  cudaMalloc( (void**)&dev_a, N*sizeof(int));
  cudaMalloc( (void**)&dev_b, N*sizeof(int));
  cudaMalloc( (void**)&dev_c, N*sizeof(int));

  cudaMemcpy(dev_a, a, N*sizeof(int), cH2D);
  cudaMemcpy(dev_b, b, N*sizeof(int), cH2D);

  add <<< N, NumThreads >>> (dev_a, dev_b, dev_c);

  cudaMemcpy(&c, dev_c, N*sizeof(int), cD2H);

  for(int i = 0; i< N; i++){
    printf("%d + %d = %d\n", a[i], b[i], c[i]);
  }

  cudaFree(dev_a);
  cudaFree(dev_b);
  cudaFree(dev_c);

  return 0;
}
