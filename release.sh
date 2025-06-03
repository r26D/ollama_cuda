#!/bin/bash

set -e  # Exit on any error

# --- Configuration ---
RELEASE_BRANCH="release"
TAG_NAME="$1"

if [[ -z "$TAG_NAME" ]]; then
  echo "Usage: $0 <version-tag>"
  echo "Example: $0 v1.0.0"
  exit 1
fi

# --- Step 1: Checkout main branch ---
git checkout main
git pull origin main

# --- Step 2: Create or update release branch ---
git checkout -B "$RELEASE_BRANCH"
git push origin "$RELEASE_BRANCH"

# --- Step 3: Tag the release ---
git tag -a "$TAG_NAME" -m "Release $TAG_NAME"
git push origin "$TAG_NAME"

echo "Release $TAG_NAME pushed to '$RELEASE_BRANCH' and tagged."

