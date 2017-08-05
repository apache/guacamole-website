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

/**
 * Assigns click event handlers to all elements with the "dropdown-toggle"
 * class which toggle the "open" class of the nearest ancestor element with the
 * "dropdown" class. An additional click event handler is added to the body
 * element which removes the "open" class of all "dropdown" elements, thus
 * closing all open dropdowns when the user clicks outside the menu.
 */
(function initDropdowns() {

    // Automatically toggle the open state of dropdowns when their trigger
    // element is clicked
    $('.dropdown-toggle').click(function dropdownClicked(e) {

        // Find the relevant dropdown element
        var clicked = $(e.target).closest('.dropdown');

        // Close all other open dropdowns
        $('.dropdown').not(clicked).removeClass('open');

        // Toggle the open state of the clicked dropdown
        clicked.toggleClass('open');
        e.preventDefault();

    });

    // Prevent clicks within the menu from propogating to ancestor elements
    $('.dropdown').click(function dropdownClicked(e) {
        e.stopPropagation();
    });

    // Automatically close any open dropdown menus when the user clicks
    // elsewhere
    $('body').click(function closeDropdowns() {
        $('.dropdown').removeClass('open');
    });

})();

