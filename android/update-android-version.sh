#!/bin/bash

BUILD_GRADLE="app/build.gradle"

# make a backup of build.gradle
cp $BUILD_GRADLE "$BUILD_GRADLE.bak"

# Fetch current versionCode
CURRENT_VERSION_CODE=$(grep -oP '(?<=versionCode )\d+' $BUILD_GRADLE)
NEW_VERSION_CODE=$((CURRENT_VERSION_CODE + 1))

# Define new versionName (pass as an argument, default: 1.0.X)
NEW_VERSION_NAME=${1:-"1.0.$NEW_VERSION_CODE"}

echo "Updating versionCode: $CURRENT_VERSION_CODE -> $NEW_VERSION_CODE"
echo "Updating versionName: $(grep -oP '(?<=versionName ")[^"]+' $BUILD_GRADLE) -> $NEW_VERSION_NAME"

# Update versionCode
sed -i "s/versionCode $CURRENT_VERSION_CODE/versionCode $NEW_VERSION_CODE/" $BUILD_GRADLE

# Update versionName
sed -i "s/versionName \"[^\"]*\"/versionName \"$NEW_VERSION_NAME\"/" $BUILD_GRADLE

echo "Build.gradle updated successfully!"
