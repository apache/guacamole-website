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
# Dockerfile for guacamole-website
# 
# See the README for more information on how to use this file.

# Perform the build using ruby and jekyll 
FROM ruby

# Install jeykll
RUN gem install jekyll bundler

# Set the working directory for the remainder of the build process
WORKDIR /website

# Copy the website source into the working directory and build it
COPY ./ ./
RUN ./build.sh

# The port at which the website should be hosted. Make sure to
# expose this port when running this docker image.
ENV PORT=8080

# Host the website at the configured port
CMD ["sh", "-c", "./build.sh ${PORT}"] 
