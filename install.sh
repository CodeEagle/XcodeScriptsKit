#!/bin/bash

TOOLS_LOCATION="/Users/$USER/bin"
mkdir -p $TOOLS_LOCATION && cd $TOOLS_LOCATION
XCODE_SCRIPTS_KIT_LOCATION="$TOOLS_LOCATION/XcodeScriptsKit"
if [ -d "$XCODE_SCRIPTS_KIT_LOCATION" ]; then
  if [ -d ".git" ]; then
    git reset --hard HEAD && git pull
  else
    rm -rf $XCODE_SCRIPTS_KIT_LOCATION
    git clone --depth=1 "https://github.com/CodeEagle/XcodeScriptsKit.git"
  fi
else
  git clone --depth=1 "https://github.com/CodeEagle/XcodeScriptsKit.git"
fi
