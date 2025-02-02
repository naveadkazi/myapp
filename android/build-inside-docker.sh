#!/bin/bash -e

# Pass in build number, so we can adjust version
VERSION_NAME="$1"
if [ -z "$VERSION_NAME" ]; then
        echo "usage: $0 <VERSION_NAME>"
        exit 1
fi

# Pretty output of log msgs with yellow color
function msg {
        echo -e "\e[1;33m[APP-BUILD]\e[0m $1"
}

# Install dependencies and build React Native code
#msg "(1/5) Build React Native code"
#yarn
#yarn android-build

# Gradle clean
msg "(2/5) Gradle clean"
cd android
./gradlew clean

# Update version coed and version name
msg "(3/5) Update version"
chmod +x ./update-android-version.sh
./update-android-version.sh ${VERSION_NAME}

# Build Android app using Gradle
msg "(4/5) Gradle build"
./gradlew bundleRelease

# Sanity check that build was created
outfile="$(pwd)/app/build/outputs/bundle/release/app-release.aab"
msg "(5/5) Check .aab was created"
if [ -f "$outfile" ]; then
        echo "SUCCESS: Output is here: $outfile"
else
        echo "ERROR: Output does NOT exist"
        exit 99
fi