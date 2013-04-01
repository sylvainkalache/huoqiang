require 'exifr'

module Huoqiang

  # Return the path and copyright of picture
  #
  # @return [Array] Path and copyright of a picture
  class Image
    def self.get
      image_dir = File.join(File.expand_path(File.dirname(__FILE__)),'../public/images/')
      images = Dir.entries(image_dir)
      images.delete('..')
      images.delete('.')
      images.delete('.DS_Store')
      images.delete('.svn')
      random_nbr = rand(images.count)
      copyright  = get_copyright("images/#{images[random_nbr]}")

      return ["images/#{images[random_nbr]}", copyright]
    end

    # Return the copyright from picture's EXIF
    #
    # @param [String] Picture path
    #
    # @return [String]
    def self.get_copyright(picture_path)
      EXIFR::JPEG.new( File.join(File.expand_path(File.dirname(__FILE__)),"../public/#{picture_path}")).copyright
    end
  end
end
