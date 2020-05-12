# this is a makefile - COMMENTS GO HERE
# this is comment from Filipp
# this is comment from Beksultan
# this is a comment from Atai


F1= -L/usr/local/cuda/lib64
F2= -I/usr/local/cuda-10.1/targets/x86_64-linux/include -lcuda -lcudart
F3= -lglut -lGL

all: vf

vf: interface.o gpu.o animate.o
	g++ -o template interface.o animate.o gpu.o $(F1) $(F2) $(F3)

interface.o: interface.cpp gpu.h
	g++ -c interface.cpp $(F1) $(F2)

gpu.o: gpu.cu gpu.h
	/usr/local/cuda/bin/nvcc -c gpu.cu

animate.o: animate.cu animate.h
	/usr/local/cuda/bin/nvcc -c -w animate.cu

clean:
	rm interface.o
	rm gpu.o
	rm animate.o
	rm vf
