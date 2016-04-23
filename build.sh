#!/bin/sh -e

log() {
    echo "$*" >&2
}

assert_directory() {
    NAME="$1"
    if [ ! -d doc ]; then
        log "FATAL: $NAME does not exist or is not a directory."
        exit 1
    fi
}

# Build site
jekyll build

# Verify expected directories exist
assert_directory doc
assert_directory _site

# Clean out content directory (if present)
rm -rf content/; mkdir content

# Copy site and docs into place
cp -a doc/ content/
cp -a _site/* content/

# Done

