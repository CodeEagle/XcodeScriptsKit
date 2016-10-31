#!/bin/bash
# add next line to new run script in XCode Build Phase before compile source
#
# ENABLE_BUILD_NUMBER=$1 #"1" TO ENABLE, "0" TO DISABLE
# INFO_PLIST_PATH=$2 # PATH TO info.plist
# BUILD_NUMBER_PLIST_PATH=$3 # PATH TO STORE build.plist
#
# GENERATED_CODE_PREFIX=$4 # prefix for generated code
# GENERATED_CODE_PATH=$5 # folder path to store generated code
#
# IMAGE_ASSETS_PATH=$6 # path to *.xcassets folder
# TO_FORMAT_CODE_PATH=$7 # folder that needs code format
# LANGUAGE_FILE_PATH=$8 # language file path,such as ".../zh-Hans.lproj/Localizable.strings"
# EXCEPT_TARGET_THAT_NOT_CARTHAGING=$9 # not need Integration with carthage target name
# cd ~/bin/XcodeScriptsKit && ./script_manager.sh "1" "INFO_PLIST_PATH" "BUILD_NUMBER_PLIST_PATH" "GENERATED_CODE_PREFIX" "GENERATED_CODE_PATH" "IMAGE_ASSETS_PATH" "TO_FORMAT_CODE_PATH" "LANGUAGE_FILE_PATH"
#
# and add Resource folder to Library as file referrence
# Get base path to project
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

ENABLE_BUILD_NUMBER=$1
INFO_PLIST_PATH=$2
BUILD_NUMBER_PLIST_PATH=$3

GENERATED_CODE_PREFIX=$4
GENERATED_CODE_PATH=$5

IMAGE_ASSETS_PATH=$6
TO_FORMAT_CODE_PATH=$7
LANGUAGE_FILE_PATH=$8

GENERATED_LOCATION="$GENERATED_CODE_PATH/$GENERATED_CODE_PREFIX"
BASE_PATH="$PROJECT_DIR"
# RESOURCE_BUILDER
TOOLS_LOCATION="/Users/$USER/bin/XcodeScriptsKit"
RESOURCE_BUILDER="$TOOLS_LOCATION/assets_builder.swift"
BUILD_NUMBER="$TOOLS_LOCATION/build_number.swift"
FORMAT_CODE="$TOOLS_LOCATION/format_code.swift"
CARTHAGE_HELPER="$TOOLS_LOCATION/carthage_helper.rb"

RESOURCE_OUTPUT_PATH=$GENERATED_LOCATION"Assets.swift"
echo There are $# arguments
echo  argument: $1
echo  argument: $2
echo  argument: $3
echo  argument: $4
echo  argument: $5
echo  argument: $6
echo  argument: $7
echo  argument: $8

mkdir -p "$GENERATED_CODE_PATH"
chmod 755 "$RESOURCE_BUILDER"
# set -x
# 执行文件            资源目录                  输出文件
"$RESOURCE_BUILDER" "$IMAGE_ASSETS_PATH" "$RESOURCE_OUTPUT_PATH"
RELEASE=0
if [ "${CONFIGURATION=}" == "Release" ]; then
  RELEASE=1
fi
if [ "$ENABLE_BUILD_NUMBER" = "1" ]; then
  "$BUILD_NUMBER" "$BUILD_NUMBER_PLIST_PATH" "$INFO_PLIST_PATH" "$RELEASE"
fi


set -x

#--------- START OF CONFIGURATION

# Get path to Laurine Generator script
LAURINE_PATH="$TOOLS_LOCATION/LaurineGenerator.swift"

# Get path to main localization file (usually english).
SOURCE_PATH="$LANGUAGE_FILE_PATH"

# Get path to output. If you use ObjC version of output, set implementation file (.m), as header will be generated automatically
OUTPUT_PATH=$GENERATED_LOCATION"Localizations.swift"


BASE_CLASS_NAME=$GENERATED_CODE_PREFIX"Localizations"

#--------- END OF CONFIGURATION

# Add permission to generator for script execution
chmod 755 $LAURINE_PATH

# Actually generate output. -- CUSTOMIZE -- parameters to your needs (see documentation).
# Will only re-generate script if something changed
# -ot older than
if [ "$OUTPUT_PATH" -ot "$SOURCE_PATH" ]; then
  "$LAURINE_PATH" -i "$SOURCE_PATH" -o "$OUTPUT_PATH" -b "$BASE_CLASS_NAME"
fi

"$FORMAT_CODE" "$TO_FORMAT_CODE_PATH"
