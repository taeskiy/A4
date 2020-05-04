/******************************************************************************
Hello! Ali here!!
  usage information and TODO stuff here...

******************************************************************************/


#include <stdio.h>
#include "gpu.h"



/******************************************************************************/
APopulation initializePop(unsigned int width, unsigned int height){

  APopulation P;
  P.nThreads.x = 32;  // 32 x 32 = 1024 threads per block
  P.nThreads.y = 32;
  P.nThreads.z = 1;
  P.nBlocks.x = (int) ceil(width/32.0);  // however many blocks needed for image
  P.nBlocks.y = (int) ceil(height/32.0);
  P.nBlocks.z = 1;
  P.pop_width = P.nBlocks.x * P.nThreads.x;       // save this info
  P.pop_height = P.nBlocks.y * P.nThreads.y;
  P.N = P.pop_width * P.pop_height;  // not the same as width and height

  cudaError_t err;
  err = cudaMalloc( (void**) &P.rand, P.N*sizeof(curandState));
  if(err != cudaSuccess){
     printf("cuda error allocating rand = %s\n", cudaGetErrorString(err));
     exit(EXIT_FAILURE);
     }

  err = cudaMalloc( (void**) &P.red, P.N*sizeof(float));
  if(err != cudaSuccess){
     printf("cuda error allocating red = %s\n", cudaGetErrorString(err));
     exit(EXIT_FAILURE);
     }

  err = cudaMalloc( (void**) &P.green, P.N*sizeof(float));
  if(err != cudaSuccess){
     printf("cuda error allocating green = %s\n", cudaGetErrorString(err));
     exit(EXIT_FAILURE);
     }

  err = cudaMalloc( (void**) &P.blue, P.N*sizeof(float));
  if(err != cudaSuccess){
     printf("cuda error allocating red = %s\n", cudaGetErrorString(err));
     exit(EXIT_FAILURE);
     }


  setup_rands <<< P.nBlocks, P.nThreads >>> (P.rand, time(NULL), P.N);


  //----- placeholder for initializing memory with values
  // int a[P.N], b[P.N];
  // for (int i=0; i<P.N; i++){
  //   a[i] = -i;
  //   b[i] = i;
  // }
  // cudaMemcpy(P.dev_a, a, P.N*sizeof(int), cH2D);
  // cudaMemcpy(P.dev_b, b, P.N*sizeof(int), cH2D);
  // ------------------------

  return P;
}

/******************************************************************************/
int runIter(APopulation *P, unsigned long tick){

  printf("tick = %lu\n", tick);

  randomize <<< P->nBlocks, P->nThreads >>> (P->red, P->rand, P->N);
  randomize <<< P->nBlocks, P->nThreads >>> (P->green, P->rand, P->N);
  randomize <<< P->nBlocks, P->nThreads >>> (P->blue, P->rand, P->N);
  kernel <<< P->nBlocks, P->nThreads >>> (P->red, P->green, P->blue, P->N);


//  add <<< P->nBlocks, P->nThreads >>> (P->dev_a, P->dev_b, P->dev_c);


  // -- crud...
  // int a[P->N], b[P->N], c[P->N];
  // cudaMemcpy(&a, P->dev_a, P->N * sizeof(int), cD2H);
  // cudaMemcpy(&b, P->dev_b, P->N * sizeof(int), cD2H);
  // cudaMemcpy(&c, P->dev_c, P->N * sizeof(int), cD2H);
  //
  // for(int i = 0; i< P->N; i++){
  //   printf("%d + %d = %d\n", a[i], b[i], c[i]);
  //   }
  // ----

  return 0;
}





/******************************************************************************/
// Mike Brady's Kernel
__global__ void
kernel(float* red, float* green, float* blue, unsigned long N){

  int x = threadIdx.x + (blockIdx.x * blockDim.x);
  int y = threadIdx.y + (blockIdx.y * blockDim.y);
  unsigned long tid = x + (y * blockDim.x * gridDim.x);

  if(tid < N){
      red[tid] = .5;
      blue[tid] = .7;
      green[tid]= .2;
    }
}

/******************************************************************************/
__global__ void
setup_rands(curandState* rand, unsigned long seed, unsigned long N)
{

  int x = threadIdx.x + (blockIdx.x * blockDim.x);
  int y = threadIdx.y + (blockIdx.y * blockDim.y);
  unsigned long tid = x + (y * blockDim.x * gridDim.x);

  if(tid < N) curand_init(seed, tid, 0, &rand[tid]);

}

/******************************************************************************/
__global__ void
randomize(float* array, curandState* rand, unsigned long N)
{
  int x = threadIdx.x + (blockIdx.x * blockDim.x);
  int y = threadIdx.y + (blockIdx.y * blockDim.y);
  unsigned long tid = x + (y * blockDim.x * gridDim.x);

  if(tid < N){
    curandState localState = rand[tid]; // get local curandState as seed
    float theRand = curand_uniform(&localState); // use to get value from 0-1
    rand[tid] = localState; // save new state as previous state for next gen

    array[tid] = theRand;
   }

}






/******************************************************************************/
void freeGPU(APopulation *P)
{
  cudaFree(P->red);
  cudaFree(P->green);
  cudaFree(P->blue);
  cudaFree(P->rand);

  //   cudaFree(P->dev_a);
  // cudaFree(P->dev_b);
  // cudaFree(P->dev_c);
}

/******************************************************************************/
