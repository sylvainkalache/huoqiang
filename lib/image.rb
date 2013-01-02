module Huoqiang

  # Return the path to a picture picked up randomly
  #
  # @return [String] Path to a picture
  class Image
    def self.get
      image_dir = File.join(File.expand_path(File.dirname(__FILE__)),'../public/images/')
      images = Dir.entries(image_dir)
      images.delete('..')
      images.delete('.')
      images.delete('.DS_Store')
      images.delete('.svn')
      random_nbr = rand(images.count)
      return "images/#{images[random_nbr]}"
    end
  end
end
