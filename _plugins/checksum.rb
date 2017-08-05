require 'digest'

module GuacChecksumFilter

    #
    # Returns an arbitrary, unique checksum for the given file, calculated from
    # the file's contents. The resulting checksum is guaranteed to be safe for
    # inclusion within URLs.
    #
    # == Parameters:
    # input::
    #     The name of the file to use to generate the checksum.
    # 
    # == Returns:
    # An arbitrary, unique checksum generated from the contents of the given
    # file.
    #
    def checksum(input)
        digest = Digest::MD5.file input
        digest.hexdigest
    end

end

# Register checksum filter with Liquid
Liquid::Template.register_filter(GuacChecksumFilter)

