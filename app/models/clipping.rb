class Clipping < ActiveRecord::Base

  belongs_to :story
  
  has_attachment(:content_type => :image,
                 :storage => :s3,
                 :max_size => 3.megabytes,
                 :thumbnails => { :preview => '420x315!', :full => '320x240!', :large => [128,128], :medium => [96,96], :small => [64,64], :tiny => [48,48] },
                 :processor => 'Rmagick')
  validates_as_attachment

  # overload resize image
  # see: http://toolmantim.com/article/2006/9/12/generating_cropped_thumbnails_with_acts_as_attachment
  def resize_image(img, size)
    size = size.first if size.is_a?(Array) && size.length == 1 && !size.first.is_a?(Fixnum)
    if size.is_a?(Fixnum) || (size.is_a?(Array) && size.first.is_a?(Fixnum))
      size = [size, size] if size.is_a?(Fixnum)
      #img.thumbnail!(*size)
      # fix from: http://pastie.org/58467
      size[0] == size[1] ? img.crop_resized!(*size) : img.thumbnail!(*size)
      # This elsif extends
    elsif size.is_a?(Hash)
      dx, dy = size[:crop].split(':').map(&:to_f)
      w, h = (img.rows * dx / dy), (img.columns * dy / dx)
      img.crop!(::Magick::CenterGravity, [img.columns, w].min, [img.rows, h].min)
      size = size[:size]
      w2, h2 = size.split('x').map(&:to_f)
      img.resize!(w2,h2)
    else
      # img.change_geometry(size.to_s) { |cols, rows, image| image.resize!(cols, rows) }
      img.change_geometry(size.to_s) { |cols, rows, image| image.resize!(cols<1 ? 1 : cols, rows<1 ? 1 : rows) }
    end
    img.strip! unless attachment_options[:keep_profile]
    temp_paths.unshift write_to_temp_file(img.to_blob)
    # self.temp_path = write_to_temp_file(img.to_blob)
  end

end
