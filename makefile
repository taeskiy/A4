# this is a makefile - COMMENTS GO HERE

F1= -L/usr/local/cuda/lib64
F2= -I/usr/local/cuda-10.1/targets/x86_64-linux/include -lcuda -lcudart
F3= -lglut -lGL

all: template

template: interface.o gpu.o animate.o
	g++ -o template interface.o animate.o gpu.o $(F1) $(F2) $(F3)

interface.o: interface.cpp gpu.h
	g++ -c interface.cpp $(F1) $(F2)

gpu.o: gpu.cu gpu.h
	/usr/local/cuda/bin/nvcc -c gpu.cu

animate.o: animate.cu animate.h
	/usr/local/cuda/bin/nvcc -c animate.cu

# more files to compile will go here

clean:
	rm interface.o
	rm gpu.o
