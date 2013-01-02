module Huoqiang
  class Image
    def self.get
      image_dir = File.join(File.expand_path(File.dirname(__FILE__)),'../public/images/')
      images = Dir.entries(image_dir)
      images.delete('..')
      images.delete('.')
      images.delete('.DS_Store')
      random_nbr = rand(images.count)
      return "images/#{images[random_nbr]}"
    end
  end
end