#!/usr/bin/env bash

to_pid=$(ps -ef | grep timeout | grep -v grep | awk -F ' ' '{print $2}')

if [ -z "$to_pid" ]; then
  echo "No timeout process found..."
else
  echo "Killing PID ${to_pid}"
  kill $to_pid
fi
