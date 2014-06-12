#!/bin/bash
 
MIN=-131072
MAX=131071
RF=`busybox dc ${1:-1.0} 0.5 mul p`
RO=`busybox dc ${2:-0.0} 65536 mul p`
GF=`busybox dc ${3:-1.0} 0.5 mul p`
GO=`busybox dc ${4:-0.0} 65536 mul p`
BF=`busybox dc ${5:-1.0} 0.5 mul p`
BO=`busybox dc ${6:-0.0} 65536 mul p`
 
./lut_conf3 -N 4096 -m $MIN -M $MAX -F $RF -O $RO -B 0x60500000
./lut_conf3 -N 4096 -m $MIN -M $MAX -F $GF -O $GO -B 0x60504000
./lut_conf3 -N 4096 -m $MIN -M $MAX -F $GF -O $GO -B 0x60508000
./lut_conf3 -N 4096 -m $MIN -M $MAX -F $BF -O $BO -B 0x6050C000

