#!/bin/bash

TOOLS_LOCATION="/Users/$USER/bin/"
mkdir -p $TOOLS_LOCATION && cd $TOOLS_LOCATION
git clone --depth=1 "git@github.com:CodeEagle/XcodeScriptsKit.git"
XCODE_SCRIPTS_KIT_LOCATION="$TOOLS_LOCATION/XcodeScriptsKit"
cd $XCODE_SCRIPTS_KIT_LOCATION && rm -rf .git
