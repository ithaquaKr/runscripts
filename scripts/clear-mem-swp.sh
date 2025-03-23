#!/usr/bin/env bash
# Script Name: clear-mem-swp.sh
# Description: This script use to clear the swap memory.
# Maintainer: Ithadev Ng <ithadev.nguyen@gmail.com>
# Last Updated: 2025-03-11
# Version: 0.1

echo "Clean mem, swp starting...."
swapoff -a && swapon -a
sync && echo 1 >/proc/sys/vm/drop_caches
echo "done........ <3"
