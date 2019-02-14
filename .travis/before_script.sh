#!/bin/bash

cd $HOME
pwd

if [ -z ./flutter ]; then
    echo "~~~ No cached Flutter is available"
    git clone https://github.com/flutter/flutter.git
fi

echo "~~~ Upgrading cached Flutter..."

cd ./flutter
pwd
git fetch --all --prune
git checkout beta
cd ..
pwd

PATH="$HOME/flutter/bin:$PATH"
flutter doctor
