#!/usr/bin/perl -i -p
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
# add-tracking.pl: Adds Google Analytics tracking code to HTML files.
#
# This script edits HTML files in-place, adding Google Analytics tracking code
# just before the </body> tag.
#
# Note that the Apache Guacamole website includes the tracking code on all
# pages which are processed through Jekyll, as it is part of the default
# layout. This must be manually done only to HTML which will not be processed,
# like the manual and API documentation.
#
# EXAMPLE USAGE:
#
#     find -name "*.html"                    \
#         | xargs grep -L "Google Analytics" \
#         | xargs ./add-tracking.pl
#
# -----------------------------------------------------------------------------
#

use strict;
use warnings;

# Tracking code
my $TRACKING = <<'END';
        <!-- Google Analytics -->
        <script type="text/javascript">
          (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
          (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
          m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
          })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

          ga('create', 'UA-75289145-1', 'auto');
          ga('send', 'pageview');
        </script>
END

s/(\s*<\/body>)/$TRACKING$1/i;

