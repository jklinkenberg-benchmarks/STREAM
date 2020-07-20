FLAGS_OPENMP?=-fopenmp

CC ?= gcc
CFLAGS ?= -O3 ${FLAGS_OPENMP}

FC ?= gfortran
FFLAGS ?= -O3 ${FLAGS_OPENMP}

STREAM_ARRAY_SIZE?=600000000
NTIMES?=40

all: stream_f.exe stream_c.exe

stream_f.exe: stream.f mysecond.o
	$(CC) $(CFLAGS) -c mysecond.c
	$(FC) $(FFLAGS) -c stream.f
	$(FC) $(FFLAGS) stream.o mysecond.o -o stream_f.exe

stream_c.exe: stream.c
	$(CC) $(CFLAGS) -DSTREAM_ARRAY_SIZE=${STREAM_ARRAY_SIZE} -DNTIMES=${NTIMES} stream.c -o stream_c.exe

clean:
	rm -f stream_f.exe stream_c.exe *.o stream*.icc

# an example of a more complex build line for the Intel icc compiler
stream.icc: stream.c
	icc -O3 -xHost -ffreestanding -qopenmp -qopt-streaming-stores=always -DSTREAM_ARRAY_SIZE=${STREAM_ARRAY_SIZE} -DNTIMES=${NTIMES} stream.c -o stream.omp.icc

stream.ncc: 
	ncc -O3 -fopenmp -DSTREAM_ARRAY_SIZE=${STREAM_ARRAY_SIZE} -DNTIMES=${NTIMES} stream.c -o stream.omp.ncc
