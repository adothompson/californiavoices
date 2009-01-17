class Clipping < ActiveRecord::Base

  belongs_to :story
  
  has_attachment(:content_type => :image,
                 :storage => :s3,
                 :max_size => 1.megabyte,
                 :thumbnails => { :full => '320x240!', :main => '100x67!', :large => '128>', :medium => '96>', :small => '64>', :tiny => '48>'},
                 :processor => 'Rmagick')
  validates_as_attachment
  
end
