#!/bin/bash

TOOLS_LOCATION="/Users/$USER/bin"
mkdir -p $TOOLS_LOCATION && cd $TOOLS_LOCATION
XCODE_SCRIPTS_KIT_LOCATION="$TOOLS_LOCATION/XcodeScriptsKit"
rm -rf XCODE_SCRIPTS_KIT_LOCATION
git clone --depth=1 "https://github.com/CodeEagle/XcodeScriptsKit.git"
cd $XCODE_SCRIPTS_KIT_LOCATION && rm -rf .git
