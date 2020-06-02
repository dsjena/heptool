#!/bin/bash
#--------------------------------------
# Satyajit Jena
# Date: 2015/09/20
# this is a template for various 
# software dependencies installation 
#-------------------------------------

# set -e for a while during test off

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

    case ${OS} in
        Debian)
        DOUBUNTU=1
        ;;
        Ubuntu)
        DOUBUNTU=1
        ;;
        CentOS)
        DOREDHAT=1
        ;;
        Redhat)
        DOREDHAT=1
        ;;
        *)
        DOUBUNTU=0
        DOREDHAT=0
        ;;
    esac
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
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    brew doctor
    brew install autoconf
    brew install automake
    brew install cmake
}


function SetRedHat() {

    sudo yum install git \
        cmake \
        gcc-c++ \
        gcc \
        binutils \
        libX11-devel \
        libXpm-devel \
        libXft-devel \
        libXext-devel

    sudo yum install gcc-gfortran \ 
        openssl-devel \
        pcre-devel \
        mesa-libGL-devel \
        mesa-libGLU-devel \
        glew-devel \
        ftgl-devel \
        mysql-devel \
        fftw-devel \
        cfitsio-devel \
        graphviz-devel \
        avahi-compat-libdns_sd-devel \
        libldap-dev python-devel \
        libxml2-devel \
        gsl-static

}


function SetUbuntu() {

    sudo apt-get update

    sudo apt-get install git \
        dpkg-dev \
        cmake \
        g++ \
        gcc \
        binutils \
        libx11-dev \
        libxpm-dev \
        libxft-dev \
        libxext-dev

    sudo apt-get install gfortran \
        libssl-dev \
        libpcre3-dev \
        xlibmesa-glu-dev \
        libglew1.5-dev \
        libftgl-dev \
        libmysqlclient-dev \
        libfftw3-dev \
        libcfitsio-dev \
        graphviz-dev \
        libavahi-compat-libdnssd-dev \
        libldap2-dev \
        python-dev \
        libxml2-dev \	
        libkrb5-dev \
        libgsl0-dev \
        libqt4-dev

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


  
