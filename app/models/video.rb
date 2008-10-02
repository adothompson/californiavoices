class Video < ActiveRecord::Base
  
  # relationships
  belongs_to :story
  #belongs_to :encoding_profile
  #has_one :encoding_job
  
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
                 :max_size => 300.megabytes
                 )
  validates_as_attachment
  
end
