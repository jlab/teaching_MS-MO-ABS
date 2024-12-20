#!/bin/bash

first_number=$1
second_number=$2

if [ $first_number -lt $second_number ]; then
  echo "$first_number is smaller than $second_number"
elif [ $first_number -eq $second_number ]; then
  echo "$first_number is equal to $second_number"
elif [ $first_number -gt $second_number ]; then
  echo "$first_number is greater than $second_number"
else
  echo "this is wired. Are your inputs numbers? first: '$first_number' and second: '$second_number'"
fi
