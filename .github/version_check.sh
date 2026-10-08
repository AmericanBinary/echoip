#!/bin/bash

# Function to compare two version numbers
version_gt() { test "$(printf '%s\n' "$@" | sort -V | tail -n 1)" == "$1"; }

# Get the current version from the version file
current_version=$(cat version/version.go | grep 'const Version' | awk '{print $NF}' | tr -d '"')

# Get the previous version from the latest tag
previous_version=$(git describe --tags $(git rev-list --tags --max-count=1) | tr -d 'v')

if [ "$current_version" == "$previous_version" ]; then
  echo "1" > check.txt
else
  echo "2" > check.txt
fi

if version_gt "$current_version" "$previous_version"; then
    echo "Version check passed. Building..."
    echo "Current version: $current_version, Previous version: $previous_version"
    exit 0
else
    echo "Error: Version must be strictly incremented. Current version: $current_version, Previous version: $previous_version"
    exit 1
fi