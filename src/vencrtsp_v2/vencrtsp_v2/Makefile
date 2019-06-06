# Hisilicon Hi3516 sample Makefile

#include ../Makefile.param
#ifeq ($(SAMPLE_PARAM_FILE), )
#     SAMPLE_PARAM_FILE:=../Makefile.param
#     include $(SAMPLE_PARAM_FILE)
#endif

# target source
SRC  := $(wildcard *.c)
OBJ  := $(SRC:%.c=%.o)

CFLAGS+=-I. -I/data/camera/sdk/Hi3518E_SDK_V1.0.4.0/mpp/sample/common -I/data/camera/sdk/Hi3518E_SDK_V1.0.4.0/mpp/include

TARGET := $(OBJ:%.o=%)
.PHONY : clean all

all: $(TARGET)

#MPI_LIBS := $(REL_LIB)/libmpi.a

$(TARGET):%:%.o $(COMM_OBJ)
	$(CC) $(CFLAGS) -lpthread -lm -o $@ $^ $(MPI_LIBS) $(AUDIO_LIBA) $(SENSOR_LIBS)

clean:
	@rm -f $(TARGET)
	@rm -f $(OBJ)
	@rm -f $(COMM_OBJ)

cleanstream:
	@rm -f *.h264
	@rm -f *.jpg
	@rm -f *.mjp
	@rm -f *.mp4
