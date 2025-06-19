#!/usr/bin/env bash

e=$(networksetup -getwebproxy wi-fi | grep "No")

if [ -n "$e" ]; then
  echo "Turning on proxy"
  networksetup -setwebproxystate wi-fi on
  networksetup -setsecurewebproxystate wi-fi on
  networksetup -setsecurewebproxy wi-fi 10.161.11.42 3128 off
  networksetup -setwebproxy wi-fi 10.161.11.42 3128 off
else
  echo "Turning off proxy"
  networksetup -setwebproxystate wi-fi off
  networksetup -setsecurewebproxystate wi-fi off
fi
