#!/bin/sh -e

log() {
    echo "$*" >&2
}

assert_directory() {
    NAME="$1"
    if [ ! -d doc ]; then
        log "FATAL: \"$NAME\" does not exist or is not a directory."
        exit 1
    fi
}

assert_program() {
    NAME="$1"
    if ! which "$NAME" &> /dev/null; then
        log "FATAL: \"$NAME\" is not installed."
        exit 1
    fi
}

build() {

    # Verify required programs are installed
    assert_program jekyll

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

}

serve() {

    # Verify required programs are installed
    assert_program ruby

    # Run server
    ruby -run -e httpd content/ -p "$1"

}

# Verify number of arguments
if [ "$#" -gt 1 -o "$1" = "-h" ]; then
    log "Usage:"
    log "    $0 -h       # Display this message"
    log "    $0          # Build website"
    log "    $0 PORT     # Build website and serve from the given PORT"
    exit 1
fi

# Build in all cases
build

# Serve on requested port
if [ -n "$1" ]; then
    serve "$1"
fi

