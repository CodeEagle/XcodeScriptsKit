#!/bin/bash
PREVIOUS_FOLDER="$pwd"
TOOLS_LOCATION="/Users/$USER/bin"
mkdir -p $TOOLS_LOCATION && cd $TOOLS_LOCATION
XCODE_SCRIPTS_KIT_LOCATION="$TOOLS_LOCATION/XcodeScriptsKit"
GIT_DIR=$XCODE_SCRIPTS_KIT_LOCATION"/.git"
if [ -d "$XCODE_SCRIPTS_KIT_LOCATION" ]; then
  if [ -d "$GIT_DIR" ]; then
    echo "has git"
    cd $XCODE_SCRIPTS_KIT_LOCATION
    git reset --hard HEAD && git pull
  else
    echo "no git"
    rm -rf $XCODE_SCRIPTS_KIT_LOCATION
    git clone --depth=1 "https://github.com/CodeEagle/XcodeScriptsKit.git"
  fi
else
  echo "no folder"
  git clone --depth=1 "https://github.com/CodeEagle/XcodeScriptsKit.git"
fi
cd "$PREVIOUS_FOLDER"
