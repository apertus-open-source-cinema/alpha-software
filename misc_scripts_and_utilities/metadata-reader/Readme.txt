metadatareader
--------------


Copyright (C):
--------------
Sebastian Pichelhofer (apertus°) 2013


About:
------
read the 128x16bit block via piped stdin and display it in a human readable format


Compiling:
---------
simply type "make"


Usage Example:
--------------
cat image.raw16 | dd bs=256 skip=98304 | ./metadatareader 

The included meta.dump is an example 128x16bit block extracted from an image 
cat meta.dump | ./metadatareader 


Parameters:
-----------
-h		print help message
-r		print raw registers
-swap-endian	swap endianess of piped binary input
