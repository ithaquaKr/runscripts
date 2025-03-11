#!/bin/bash

PROXY=""
NO_PROXY=""

set_proxy() {
  export http_proxy="$PROXY"
  export https_proxy="$PROXY"
  export no_proxy="$NO_PROXY"
  export HTTP_PROXY="$PROXY"
  export HTTPS_PROXY="$PROXY"
  export NO_PROXY="$NO_PROXY"
  echo "Proxy: $PROXY has been setup ~~!"
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

unset_proxy
set_proxy
