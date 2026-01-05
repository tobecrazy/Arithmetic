#!/bin/sh

#  set_git_info.sh
#  Arithmetic
#
#  This script extracts the latest git commit hash and message and
#  writes them to a file that will be included in the app bundle.
#  This allows the app to display git information in the "About" screen.

# Set the path for the output file
APPVERSION_FILE_PATH="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/appversion.txt"

# Get the latest git commit hash (short version)
COMMIT_HASH=$(git rev-parse --short HEAD)

# Get the latest git commit message
COMMIT_MESSAGE=$(git log -1 --pretty=%B)

# Write the commit hash and message to the file, separated by a delimiter
echo "${COMMIT_HASH}_||_${COMMIT_MESSAGE}" > "${APPVERSION_FILE_PATH}"

echo "App version info set in appversion.txt"
