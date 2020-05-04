/******************************************************************************

  COMMENTS, AUTHORSHIP, TODO ETC. GOES HERE

/******************************************************************************/
#include <stdio.h>
#include <unistd.h>
#include "gpu.h"
#include "animate.h"


/******************************************************************************/
int runIt(APopulation* thePop, CPUAnimBitmap* theAnimation){

  for(unsigned long tick=0; tick < 10; tick++){

    runIter(thePop, tick);

    theAnimation->drawPalette();

    usleep(1000000); // pause 1 second
    }

  return 0;
}

/******************************************************************************/
int main(){

  // create memory on GPU
  APopulation thePop = initializePop(800, 800); // width, height


  // create drawing palette
  CPUAnimBitmap animation(&thePop);
  cudaMalloc((void**) &animation.dev_bitmap, animation.image_size());
  animation.initAnimation();

  runIt(&thePop, &animation);

  freeGPU(&thePop);

  return 0;
}
