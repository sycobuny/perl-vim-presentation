#!/bin/bash

root=$(dirname "$BASH_SOURCE")
cwd=`pwd`
cd $root

which git 2>&1 1>/dev/null
if [[ $? -ne 0 ]]; then
    echo "You don't have git installed, and I need that!"
    echo "You can't clone any dependencies for this project without git."
    if [[ "$0" == "$BASH_SOURCE" ]]; then
        exit 1
    fi
else
    echo "Trying to make sure all git submodules are cloned..."
    git submodule init   1>/dev/null
    git submodule update 1>/dev/null

    if [[ $? -ne 0 ]]; then
        echo -n "Failed to clone the necessary repositories, please try "
        echo    "again later"
        if [[ "$0" == "$BASH_SOURCE" ]]; then
            exit 1
        fi
    else
        echo "All cloned!"
        echo ""

        echo "Trying to install necessary vim modules..."
        vim -u .vimrc +BundleInstall +qall

        if [[ "$0" == "$BASH_SOURCE" ]]; then
            exit 0
        fi
    fi
fi
