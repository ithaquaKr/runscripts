#!/bin/bash
# Script Name: fix-fn-keymap.sh
# Description: For fix my keyboard Fn
# Maintainer: Ithadev Ng <ithadev.nguyen@gmail.com>
# Last Updated: 2025-03-11
# Version: 0.1

echo 0 | sudo tee /sys/module/hid_apple/parameters/fnmode
echo "Done!"
