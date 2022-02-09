FLAGS_OPENMP?=-fopenmp

CC ?= gcc
CFLAGS ?= -O3 ${FLAGS_OPENMP}

FC ?= gfortran
FFLAGS ?= -O3 ${FLAGS_OPENMP}

STREAM_ARRAY_SIZE?=200000000
NTIMES?=40
READ_ONLY?=0
READ_ONLY_REDUCTION?=1

COMMON_COMPILE_FLAGS=-DSTREAM_ARRAY_SIZE=${STREAM_ARRAY_SIZE} -DNTIMES=${NTIMES} -DREAD_ONLY=${READ_ONLY} -DREAD_ONLY_REDUCTION=${READ_ONLY_REDUCTION}

all: stream_f.exe stream_c.exe

stream_f.exe: stream.f mysecond.o
	$(CC) $(CFLAGS) -c mysecond.c
	$(FC) $(FFLAGS) -c stream.f
	$(FC) $(FFLAGS) stream.o mysecond.o -o stream_f.exe

stream_c.exe: stream.c
	$(CC) $(CFLAGS) ${COMMON_COMPILE_FLAGS} stream.c -o stream_c.exe

clean:
	rm -f stream_f.exe stream_c.exe *.o stream*.icc

# an example of a more complex build line for the Intel icc compiler
stream.icc: stream.c
	icc -O3 -xHost -ffreestanding -qopenmp -qopt-streaming-stores=always -qopt-zmm-usage=high -mcmodel=medium ${COMMON_COMPILE_FLAGS} stream.c -o stream.omp.icc${EXE_SUFFIX}

latency.icc: stream_latency.c
	icc -O3 -xHost -ffreestanding -qopenmp -qopt-streaming-stores=always -qopt-zmm-usage=high -mcmodel=medium ${COMMON_COMPILE_FLAGS} stream_latency.c -o latency.omp.icc${EXE_SUFFIX}

stream.ncc: 
	ncc -O3 -fopenmp ${COMMON_COMPILE_FLAGS} stream.c -o stream.omp.ncc${EXE_SUFFIX}
