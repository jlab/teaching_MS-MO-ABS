#!/bin/bash

# $1 = SSH Host for Tunneling
# $2 = Local Socks Port
# $3 = Firefox Profile
# written by Nils Mittler

if [ $# -ne 3 ]; then
  echo "Script must be called with Socks Port and Firefox Profile"
  exit 1
fi

echo "Tunneling to $1 using Port $2 as local Socks Port and Firefox profile $3"

ssh -D "127.0.0.1:$2" -qNT "$1" &
SSH_PID=$!

firefox -no-remote -P "$3" &
FF_PID=$!

wait $FF_PID

echo "FF terminated, terminating SSH..."

kill $SSH_PID && echo "SSH terminated"
