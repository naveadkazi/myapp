#!/bin/bash -e

# Pretty output of log msgs with yellow color
function msg {
        echo -e "\e[1;33m[APP-BUILD]\e[0m $1"
}

# Default build command
BUILD_COMMAND=${1:-bundleRelease}
if [[ ! "$BUILD_COMMAND" =~ ^(assemble|bundle)(.*)(Debug|Release)$ ]]; then
    msg "Error: Invalid build command format. Must be (assemble|bundle)(Flavor?)(Debug|Release)"
    exit 1
fi

# Gradle clean
msg "(1/3) Gradle clean"
cd android
./gradlew clean

# Detect build type (Debug or Release)
BUILD_TYPE=$(echo "$BUILD_COMMAND" | grep -Eo 'Debug|Release' || echo "Release")
#Convert to lowercase
BUILD_TYPE_LOWER=$(echo "$BUILD_TYPE" | tr '[:upper:]' '[:lower:]')

# Detect flavor (if any)
# Extract Flavor (anything between 'assemble' or 'bundle' and 'Type')
FLAVOR=$(echo "$BUILD_COMMAND" | sed -E 's/^(assemble|bundle)(.*)?(Debug|Release)$/\2/' | sed 's/^$/default/')
#Convert to lowercase
FLAVOR_LOWER=$(echo "$FLAVOR" | tr '[:upper:]' '[:lower:]')

# Determine default output filename if not provided
if [[ "$BUILD_COMMAND" == *"bundle"* ]]; then
    if [[ "$FLAVOR" == "default" ]]; then
        OUTPUT_PATH="app/build/outputs/bundle/${BUILD_TYPE_LOWER}"
    else
        OUTPUT_PATH="app/build/outputs/bundle/${FLAVOR_LOWER}/${BUILD_TYPE_LOWER}"
    fi
elif [[ "$BUILD_COMMAND" == *"assemble"* ]]; then
    if [[ "$FLAVOR" == "default" ]]; then
        OUTPUT_PATH="app/build/outputs/apk/${BUILD_TYPE_LOWER}"
    else
        OUTPUT_PATH="app/build/outputs/apk/${FLAVOR_LOWER}/${BUILD_TYPE_LOWER}"
    fi
else
    msg "Unknown build type, skipping output file check."
    exit 0
fi

# Build Android app using Gradle
msg "(2/3) Gradle $BUILD_COMMAND"
./gradlew "$BUILD_COMMAND"

# Sanity check that build was created
msg "(3/3) Checking if output file was created"
# Add wildcard check since the actual files have extensions
if [ -f "$OUTPUT_PATH"/*.apk ] || [ -f "$OUTPUT_PATH"/*.aab ]; then
    echo "SUCCESS: Output is here: $OUTPUT_PATH"
else
    echo "ERROR: Output does NOT exist"
    echo "$OUTPUT_PATH"
    exit 1  # Add error code for Jenkins
fi
#echo "sleeping infinity"
#sleep infinity
