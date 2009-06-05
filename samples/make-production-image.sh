#!/bin/bash

if [ $# -ne 2 ] ; then
  echo "Usage: $0 <mounted-system-folder> <absolute-path-to-image>"
  echo "Uses dump to make a complete filesystem image."
  exit 1
fi

if [ ! -d $1 ] ; then
  echo "System folder is not a directory!"
  exit 2
fi

dump -0vf $2 $1
