#!/bin/bash
PROXY=""
NO_PROXY=""

set_proxy() {
  export http_proxy="$1"
  export https_proxy="$1"
  export no_proxy="$2"
  export HTTP_PROXY="$1"
  export HTTPS_PROXY="$1"
  export NO_PROXY="$2"
  echo "Proxy: $1 has been setup ~~!"
}

unset_proxy() {
  unset http_proxy
  unset https_proxy
  unset no_proxy
  unset HTTP_PROXY
  unset HTTPS_PROXY
  unset NO_PROXY
  echo "Proxy has been unset ~~.~~"
}

TEMP=`getopt -o '' --long proxy-server:,no-proxy: -n 'proxy.sh' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

while true ; do
    case "$1" in
        --proxy-server)
            PROXY="$2" ; shift 2 ;;
        --no-proxy)
            NO_PROXY="$2" ; shift 2 ;;
        --) shift ; break ;;
        *) echo "Unknown option: $1" ; exit 1 ;;
    esac
done

if [ "$1" == "enable" ]; then
  set_proxy "$PROXY" "$NO_PROXY"
elif [ "$1" == "disable" ]; then
  unset_proxy
else
  echo "Usage: ./proxy.sh (enable|disable) [--proxy-server=http://server.com:3128] [--no-proxy=localhost]"
fi