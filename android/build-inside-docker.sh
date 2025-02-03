#!/bin/bash -e

# Pretty output of log msgs with yellow color
function msg {
        echo -e "\e[1;33m[APP-BUILD]\e[0m $1"
}

# Default build command
BUILD_COMMAND=${1:-bundleRelease}

# Gradle clean
msg "(1/3) Gradle clean"
cd android
./gradlew clean

# Detect build type (Debug or Release)
BUILD_TYPE=$(echo "$BUILD_COMMAND" | grep -Eo 'Debug|Release' || echo "Release")

# Detect flavor (if any)
# Extract Flavor (anything between 'assemble' or 'bundle' and 'Type')
FLAVOR=$(echo "$BUILD_COMMAND" | sed -E 's/^(assemble|bundle)(.*)?(Debug|Release)$/\2/' | sed 's/^$/default/')

# Determine default output filename if not provided
if [[ "$BUILD_COMMAND" == *"bundle"* ]]; then
        OUTPUT_PATH="app/build/outputs/bundle/${FLAVOR,,}/${BUILD_TYPE,,}"
elif [[ "$BUILD_COMMAND" == *"assemble"* ]]; then
        OUTPUT_PATH="app/build/outputs/apk/${FLAVOR,,}/${BUILD_TYPE,,}"
else
        msg "Unknown build type, skipping output file check."
        exit 0
fi

# Build Android app using Gradle
msg "(2/3) Gradle $BUILD_COMMAND"
./gradlew "$BUILD_COMMAND"

# Sanity check that build was created
msg "(7/3) Checking if output file was created"
if [ -f "$OUTPUT_PATH" ]; then
        echo "SUCCESS: Output is here: $OUTPUT_PATH"
        ls "$OUTPUT_PATH"
else
        echo "ERROR: Output does NOT exist"
        exit 99
fi
