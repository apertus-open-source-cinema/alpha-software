CC = g++
CFLAGS=-c -Wall
LDFLAGS=
SOURCES= src/DNGReader.cpp src/IFD.cpp src/dngwriter.cpp src/IfdEntry.cpp
OBJECTS=$(SOURCES:.cpp=.o)
C_SOURCES= src/bayer/bayer.cpp
C_OBJECTS=$(C_SOURCES:.cpp=.o)
LIB = lib/libDNG.a
EXECUTABLE=bin/dngWriter

all: $(SOURCES) $(EXECUTABLE) $(LIB) printDNG CMV12000_sRGB 
	
$(LIB):
	ar rvs $(LIB) $(OBJECTS)
$(EXECUTABLE): $(OBJECTS) 
	$(CC) $(LDFLAGS) $(OBJECTS) -o $@
printDNG: 
	$(CC) $(LDFLAGS) src/utils/printDNG.cpp $(LIB) -o bin/printDNG
CMV12000_sRGB: bayer2rgb
	$(CC) $(LDFLAGS) src/utils/CMV12000_sRGB.cpp src/bayer/bayer.o $(LIB) -o bin/CMV12000_sRGB
bayer2rgb: $(C_OBJECTS)
	$(CC) -O3 -Wall -o bin/bayer2rgb src/bayer/bayer.o src/bayer/bayer2rgb.cpp -lm
.c.o:
	gcc -std=c99 -c $< -o $@
.cpp.o:
	$(CC) $(CFLAGS) $< -o $@
	
clean:
	\rm src/*.o src/bayer/*.o src/utils/*.o lib/libDNG.a bin/*