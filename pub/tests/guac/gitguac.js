/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

var GIT_GUAC = GIT_GUAC || {};

/**
 * The commit hash or reference that should be used when loading
 * guacamole-common-js modules from git. This value is dynamically populated
 * from the value of the "commit" parameter in the query string of the URL. If
 * no such parameter is provided, "master" is used by default.
 *
 * @type {String}
 */
GIT_GUAC.COMMIT = (function getRequestedCommit() {
    var params = location.search.match(/[?&]commit=([^&]*)/);
    return (params && decodeURIComponent(params[1])) || 'master';
})();

/**
 * Dynamically loads the guacamole-common-js module having the given filename.
 * The module is read from git using the version of the source available at
 * the commit given by GIT_GUAC.COMMIT.
 *
 * Note that the module is not guaranteed to load until after the "load" event
 * for the document fires. Code which depends on the loading of this module
 * should wait until after that event to execute.
 *
 * @param {String} filename
 *     The filename of the guacamole-common-js module to load, without
 *     corresponding path, such as "Keyboard.js" or "Mouse.js".
 */
GIT_GUAC.loadModule = function loadModule(filename) {

    // Construct URL pointing to guacamole-common-js module within ASF git
    var url = 'https://gitbox.apache.org/repos/asf?'
        + 'p=guacamole-client.git;'
        + 'a=blob_plain;'
        + 'f=guacamole-common-js/src/main/webapp/modules/' + encodeURIComponent(filename) + ';'
        + 'hb=' + encodeURIComponent(GIT_GUAC.COMMIT);

    // Dynamically load module
    var script = document.createElement('script');
    script.setAttribute('type', 'text/javascript');
    script.setAttribute('src', url);
    document.head.appendChild(script);

};

