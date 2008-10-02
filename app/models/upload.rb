# == Schema Information
# Schema version: 20081002014149
#
# Table name: uploads
#
#  id           :integer(11)   not null, primary key
#  story_id     :integer(11)   
#  size         :integer(11)   
#  filename     :string(255)   
#  content_type :string(255)   
#  created_at   :datetime      
#  updated_at   :datetime      
#

class Upload < ActiveRecord::Base
  
  # relationships
  belongs_to :story
  
  # mime types:
  # Container => Mime type
  # AVI       => video/x-msvideo
  # WMV       => video/x-ms-wmv
  # FLV       => video/x-flv OR flv-application/octet-stream?
  # MPG       => video/mpeg
  # MP3       => audio/mpeg
  # MOV       => video/quicktime
  # MP4       => video/mp4
  
  # attachment_fu params
  has_attachment(:content_type => ['video/x-msvideo','video/x-ms-wmv','video/quicktime','video/mp4','video/x-flv','flv-application/octet-stream','video/mpeg','audio/mpeg'],
                 # :storage => :s3,
                 :storage => :file_system,
                 :path_prefix => 'tmp/uploads',
                 :max_size => 300.megabytes
                 )
  validates_as_attachment

end
