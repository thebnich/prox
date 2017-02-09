#!/usr/bin/env sh

# Install necessary CocoaPods.
pod install

# Create the per-user config file.
./genconfig.sh
