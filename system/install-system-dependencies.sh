#!/bin/bash
#--------------------------------------
# Satyajit Jena
# Date: 2015/09/20
# this is a template for various 
# software dependencies installation 
#-------------------------------------

set -e

export DOUBUNTU=1
export DOREDHAT=1
export BITS=32
export ARCH=""

function LinuxDetail() {
    if test -r /etc/os-release
    then
        clearenv setenv "$1" "$2" read-conf /etc/os-release printenv "$1"
    else
        clearenv setenv "$1" "$2" read-conf /usr/lib/os-release printenv "$1"
    fi
}


function checkLinux() {

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    OS=centos
else
    OS=$(uname -s)
    VER=$(uname -r)
fi


echo " Just check which linux"

}

function GetARCH() {

case $(uname -m) in
x86_64)
    ARCH=x64  # or AMD64 or Intel64 or whatever
    ;;
i*86)
    ARCH=x86  # or IA32 or Intel32 or whatever
    ;;
*)
    ;;
esac
}

function SetBITS() {
case $(uname -m) in
x86_64)
    BITS=64
    ;;
i*86)
    BITS=32
    ;;
*)
    BITS=?
    ;;
esac
}


function SetOSX() {

echo "it is mac os"

}


function SetRedHat() {

echo "Redhat varienct"
}


function SetUbuntu() {

echo "Ubuntu Version"

}




function Main() {
MMOS=0
LLOS=0
OS=""

case "$(uname -s)" in
  Linux)
    OS=linux
    MMOS=1
    checkLinux ${MMOS}
    [[ $DOUBUNTU == 1 ]] && SetUbuntu 
    [[ $DOREDHAT == 1 ]] && SetRedHat
    ;;
  Darwin)
    OS=darwin
    LLOS=1
    SetOSX
    ;;
  *_NT-*)
    OS=windows
    MMOS=0
    LLOS=0
    ;;
esac
}

Main 


  
