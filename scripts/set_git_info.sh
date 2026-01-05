#!/bin/sh

#  set_git_info.sh
#  Arithmetic
#
#  This script extracts the latest git commit hash and message and
#  writes them to files that will be included in the app bundle.
#  This allows the app to display git information in the "About" screen.

# Set the path for the output files
COMMIT_HASH_FILE_PATH="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/git_commit.txt"
COMMIT_MESSAGE_FILE_PATH="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/git_message.txt"

# Get the latest git commit hash (short version)
COMMIT_HASH=$(git rev-parse --short HEAD)

# Get the latest git commit message
COMMIT_MESSAGE=$(git log -1 --pretty=%B)

# Write the commit hash and message to the files
echo -n "${COMMIT_HASH}" > "${COMMIT_HASH_FILE_PATH}"
echo -n "${COMMIT_MESSAGE}" > "${COMMIT_MESSAGE_FILE_PATH}"

echo "Git info set: Hash=${COMMIT_HASH}, Message=${COMMIT_MESSAGE}"
