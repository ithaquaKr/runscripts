#!/bin/bash

echo "Clean mem, swp starting...."
swapoff -a && swapon -a
sync && echo 1 >/proc/sys/vm/drop_caches
echo "done........ <3"
