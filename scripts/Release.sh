#!/bin/bash

set -e

if [ -z "$1" ]
  then
    echo "Please specify the plugin version (i.e. 1.1)"
    exit 1
fi

VERSION="$1"

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
OBS_ROOT_DIR="$SCRIPTS_DIR/../../.."

echo ""
echo "*** Build Plugin for Release ***"
echo ""

MSBUILD_PATH="c:/Program Files (x86)/Microsoft Visual Studio/2019/Community/MSBuild/Current/Bin/MSBuild.exe"
SOLUTION="$OBS_ROOT_DIR/build64/plugins/win-spout/win-spout.sln"
BUILD_ARGS="/target:Rebuild /property:Configuration=Release /maxcpucount:8 /verbosity:quiet /consoleloggerparameters:Summary;ErrorsOnly;WarningsOnly"

"$MSBUILD_PATH" "$SOLUTION" $BUILD_ARGS

echo ""
echo "*** Prepare Manual Installation Directory ***"
echo ""

MANUAL_INSTALL_PLUGIN_DIR="$SCRIPTS_DIR/../manual-install-$VERSION"

mkdir -p "$MANUAL_INSTALL_PLUGIN_DIR";
if [ "$(ls -A "$MANUAL_INSTALL_PLUGIN_DIR")" ]; then
     rm -r -f "$MANUAL_INSTALL_PLUGIN_DIR"/*
fi

MANUAL_INSTALL_BIN_DIR="$MANUAL_INSTALL_PLUGIN_DIR/Bin"
mkdir -p "$MANUAL_INSTALL_BIN_DIR";

OBS_RELEASE_BIN_DIR="$OBS_ROOT_DIR/build64/rundir/Release/obs-plugins/64bit"

cp "$OBS_RELEASE_BIN_DIR/win-spout.dll" "$MANUAL_INSTALL_BIN_DIR"
cp "$OBS_RELEASE_BIN_DIR/Spout.dll" "$MANUAL_INSTALL_BIN_DIR"
cp "$OBS_RELEASE_BIN_DIR/SpoutDX.dll" "$MANUAL_INSTALL_BIN_DIR"
cp "$OBS_RELEASE_BIN_DIR/SpoutLibrary.dll" "$MANUAL_INSTALL_BIN_DIR"

MANUAL_INSTALL_DATA_DIR="$MANUAL_INSTALL_PLUGIN_DIR/Data"
mkdir -p "$MANUAL_INSTALL_DATA_DIR";

OBS_RELEASE_DATA_DIR="$OBS_ROOT_DIR/build64/rundir/Release/data/obs-plugins/win-spout/locale"

cp -R "$OBS_RELEASE_DATA_DIR" "$MANUAL_INSTALL_DATA_DIR"

echo ""
echo "*** Prepare NSI Installer ***"
echo ""

NSI_FILE="$SCRIPTS_DIR/../win-spout-installer.nsi"

sed -i 's/^!define APPVERSION .*$/!define APPVERSION "'$VERSION'"/' $NSI_FILE

MAKENSIS_PATH="c:/Program Files (x86)/NSIS/makensis.exe"

"$MAKENSIS_PATH" $NSI_FILE

echo ""
echo "*** Release Finished ***"
echo ""
