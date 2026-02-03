#! /bin/bash

echo "Libs L:"
pkg-config --libs-only-L $1

echo "Libs l:"
pkg-config --libs-only-l $1
