#!/bin/bash

# the single argument to this script is the file path that shall be backed up
file=$1

# define the default name for a directory that shall contain the back up copied of the input file
dirname=Backup

# create the target filepath: dirname + filename suffixed by the current date (year-month-day_hour-minute-second)
# avoid using PATH as variable name, as it overwrites the environment variable PATH!!
path="$dirname/$1_$(date +%Y-%m-%d_%H-%M-%S)"

# create backup directory, -p is to avoid errors should this directory already exist
mkdir -p $dirname

# create the actual file copy
# -v will write infos to stderr, -a applies the "archive" mode to the target file.
cp -av $file $path

# inform the user
echo "File $1 was backed up as a copy in $dirname."
