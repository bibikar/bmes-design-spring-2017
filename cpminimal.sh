#!/bin/sh

grep -v '^[ 	]*--' $1 | grep . > $2
# this is just for removing comments and stuff
# so it becomes possible to actually paste code into the console
# overloading it
