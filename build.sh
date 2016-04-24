#!/bin/sh -e
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

#
# -----------------------------------------------------------------------------
#
# build.sh: Automatically build the Apache Guacamole website.
#
# This script invokes Jekyll to build a static copy of the Guacamole website
# based on its Markdown and HTML source. If requested, Ruby's HTTP server will
# be started to serve the built result for the sake of testing.
#
# The built results will be available in the "content" subdirectory of the
# source tree.
#
# USAGE:
#
#     ./build.sh [HTTP SERVER PORT]
#
# -----------------------------------------------------------------------------
#

##
## Logs the given message to STDERR.
##
## @param ...
##     The message to log to STDERR.
##
log() {
    echo "$*" >&2
}

##
## Verifies that the given file exists and is a directory. If the file does not
## exist or is not a directory, an error message is logged and script execution
## is aborted.
##
## @param NAME
##     The name of the file to verify.
##
assert_directory() {
    NAME="$1"
    if [ ! -d doc ]; then
        log "FATAL: \"$NAME\" does not exist or is not a directory."
        exit 1
    fi
}

##
## Verifies that the given program is installed and within the search path. If
## the program is not installed nor within the search path, an error message is
## logged and script execution is aborted.
##
## @param NAME
##     The name of the program to verify.
##
assert_program() {
    NAME="$1"
    if ! which "$NAME" &> /dev/null; then
        log "FATAL: \"$NAME\" is not installed."
        exit 1
    fi
}

##
## Builds the website using Jekyll. The build result is copied to the "content"
## subdirectory of the current directory. If the "content" directory already
## exists, it will first be recursively removed.
##
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

##
## Serves the "content" directory using Ruby's own HTTP server.
##
## @param PORT
##     The port number on which the HTTP server should listen.
##
serve() {

    PORT="$1"

    # Verify required programs are installed
    assert_program ruby

    # Run server
    ruby -run -e httpd content/ -p "$PORT"

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

