STREAM_FILE?=stream_tasks.c

FLAGS_OPENMP?=-fopenmp
CC ?= gcc
CFLAGS ?= -O3 ${FLAGS_OPENMP}

STREAM_ARRAY_SIZE    ?= 200000000
NTIMES               ?= 40
STREAM_USE_HEAP      ?= 0
TASKS_INVERTED       ?= 0
TASKS_SINGLE_CREATOR ?= 1
TASKS_MULTIPLICATOR  ?= 32
TASK_AFFINITY        ?= 0

COMMON_COMPILE_FLAGS=-DSTREAM_ARRAY_SIZE=${STREAM_ARRAY_SIZE} -DNTIMES=${NTIMES} -DSTREAM_USE_HEAP=${STREAM_USE_HEAP} -DTASKS_INVERTED=${TASKS_INVERTED} -DTASKS_SINGLE_CREATOR=${TASKS_SINGLE_CREATOR} -DTASKS_MULTIPLICATOR=${TASKS_MULTIPLICATOR} -DTASK_AFFINITY=${TASK_AFFINITY}

all: stream_c.exe

stream_c.exe:
	$(CC) $(CFLAGS) ${COMMON_COMPILE_FLAGS} -mcmodel=medium ${STREAM_FILE} -o stream_c.exe

clean:
	rm -f stream_c.exe *.o stream*.icc

# an example of a more complex build line for the Intel icc compiler
stream.icc:
	icc -O3 -xHost -ffreestanding -qopenmp -qopt-streaming-stores=always -qopt-zmm-usage=high -mcmodel=medium ${COMMON_COMPILE_FLAGS} ${STREAM_FILE} -o stream.omp.icc

stream.ncc: 
	ncc -O3 -fopenmp ${COMMON_COMPILE_FLAGS} ${STREAM_FILE} -o stream.omp.ncc
