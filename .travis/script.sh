#!/bin/bash

pwd

echo "~~~ Running Flutter tests..."

PATH="$HOME/flutter/bin:$PATH"
flutter test
