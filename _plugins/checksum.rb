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

require 'digest'

module GuacChecksumFilter

    #
    # Returns an arbitrary, unique checksum for the files matching the given
    # glob pattern, calculated from each file's contents. The resulting checksum
    # is guaranteed to be safe for inclusion within URLs.
    #
    # == Parameters:
    # input::
    #     The glob pattern matching the files to use to generate the checksum.
    # 
    # == Returns:
    # An arbitrary, unique checksum generated from the contents of each matching
    # file.
    #
    def checksum(input)
      digest = Dir.glob(input).sort().reduce(Digest::SHA2) { |digest, filename| digest.file filename }
        digest.hexdigest
    end

end

# Register checksum filter with Liquid
Liquid::Template.register_filter(GuacChecksumFilter)

