metadatareader
--------------


Copyright (C):
--------------
Sebastian Pichelhofer, Simon Larcher (apertus°) 2013 - 2014


About:
------
read the 128x16bit metadata block of a RAW16 image via piped stdin and display it in a human readable format


Compiling:
---------
simply type "make"


Usage Example:
--------------
cat image.raw16 | dd bs=256 skip=98304 | ./metadatareader 

read.sh does the above and uses the raw16 file name as first argument and any arguments to be passed to metadatareader as second argument


The included meta.dump is an example 128x16bit block extracted from a RAW16 image 
cat meta.dump | ./metadatareader 


Parameters:
-----------
-h		print help message
-r		print raw registers
-swap-endian	swap endianess of piped binary input
