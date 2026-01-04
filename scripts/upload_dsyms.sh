#!/bin/bash

# Configuration
GOOGLE_SERVICE_INFO_PLIST="./GoogleService-Info.plist"

# Find the latest .xcarchive
echo "Finding latest .xcarchive..."
ARCHIVE_PATH=$(find ~/Library/Developer/Xcode/Archives -type d -name "*.xcarchive" -depth 2 | sort -r | head -n 1)

if [ -z "$ARCHIVE_PATH" ]; then
    echo "Error: No .xcarchive found. Please build and archive your project first."
    exit 1
fi

echo "Latest archive found: $ARCHIVE_PATH"

# Find the dSYM path within the archive
DSYM_PATH="$ARCHIVE_PATH/dSYMs"

if [ ! -d "$DSYM_PATH" ]; then
    echo "Error: dSYMs directory not found in archive: $DSYM_PATH"
    exit 1
fi

echo "dSYM path: $DSYM_PATH"

# Verify GoogleService-Info.plist exists
if [ ! -f "$GOOGLE_SERVICE_INFO_PLIST" ]; then
    echo "Error: GoogleService-Info.plist not found at $GOOGLE_SERVICE_INFO_PLIST"
    exit 1
fi

echo "GoogleService-Info.plist found: $GOOGLE_SERVICE_INFO_PLIST"

# Locate the upload-symbols tool
UPLOAD_SYMBOLS_TOOL="./scripts/upload-symbols"

if [ ! -f "$UPLOAD_SYMBOLS_TOOL" ]; then
    echo "Error: upload-symbols tool not found at $UPLOAD_SYMBOLS_TOOL"
    exit 1
fi

# Upload dSYMs
echo "Uploading dSYMs to Firebase Crashlytics..."
"$UPLOAD_SYMBOLS_TOOL" -gsp "$GOOGLE_SERVICE_INFO_PLIST" -p ios "$DSYM_PATH"

if [ $? -eq 0 ]; then
    echo "dSYMs uploaded successfully!"
else
    echo "Error: dSYM upload failed. Check the output above for details."
    exit 1
fi