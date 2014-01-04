#!/bin/sh
cat $1 | dd bs=256 skip=98304 | ./metadatareader $2
