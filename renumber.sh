#!/bin/bash

FILE_EXT="json"
num=47883

# change into the directory containing the files
cd mediterranean2

# loop through all files with the name "file_10.tif"
for file in `ls *.${FILE_EXT} | sort -t_ -k 11`; do
  # extract the original number following the underscore
  number=$(echo "$file" | sed 's/.*_\([0-9]*\)\.${FILE_EXT}/\1/')
  # add the constant number to the original number
  new_number=$(($num))
  # construct the new file name with the updated number
  new_name=$(echo "$file" | sed "s/_[0-9]*\.${FILE_EXT}/_${new_number}.${FILE_EXT}/")
  # rename the file
  echo "{$file} -> {$new_name}"
  mv "$file" "$new_name"
  num=$((num + 1))
done

