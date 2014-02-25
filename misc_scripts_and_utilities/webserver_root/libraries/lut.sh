#!/bin/bash

for n in `seq 0 64 16384`; do /sbin/devmem $(( 0x80300000 + n )) 32; done