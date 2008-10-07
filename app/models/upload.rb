# == Schema Information
# Schema version: 20081003212204
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

require 'rvideo'

class Upload < ActiveRecord::Base
  
  # relationships
  belongs_to :story
  has_many :encoding_profiles
  has_many :encoding_jobs
  
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
  
  # after create run process?
  after_create do |upload|
    logger.info "\n\n# #{self.id} #CAVOICES - #{upload.filename} uploaded.\n\n"
    upload.process
  end
    
  # Uploads --------------
    
  def process
    self.valid?
    self.read_metadata
    self.upload_to_s3
    self.add_to_queue
  end

  def valid?
    # do we need to check anything else to validate the file?
    true
  end
  
  def read_metadata
    logger.info "\n\n# #{self.id} #CAVOICES - reading metadata for #{self.temp_path}.\n\n"
    
    inspector = RVideo::Inspector.new(:file => self.temp_path)

    # create a hash of the metadata to return... use this to save the video?
    
    # raise FormatNotRecognised unless inspector.valid? and inspector.video?
        
#     self.fps = (inspector.fps rescue nil)
    
#     self.audio_codec = (inspector.audio_codec rescue nil)
#     self.audio_sample_rate = (inspector.audio_sample_rate rescue nil)
    
    logger.info "\n\n"

    upload_metadata = {
      :width => (inspector.width rescue nil), 
      :height => (inspector.height rescue nil), 
      :duration => (inspector.duration rescue nil), 
      :container => (inspector.container rescue nil), 
      :video_codec => (inspector.video_codec rescue nil), 
      :video_bitrate => (inspector.bitrate rescue nil),
      :fps => (inspector.fps rescue nil), 
      :audio_codec => (inspector.audio_codec rescue nil), 
      :audio_sample_rate => (inspector.audio_sample_rate rescue nil),
      :audio_bitrate => (inspector.audio_bitrate rescue nil), 
      :audio_channels => (inspector.audio_channels rescue nil)
    }
    
    logger.info "#{upload_metadata.to_yaml}"
    logger.info "\n\n"

    return upload_metadata
  end
  
  def upload_to_s3
    # create background process to upload to s3 - with metadata on video
    # should just require creating video object and saving to use attachfu
    true
  end
  
  def add_to_queue
    # for each encoding profile create an encodingjob w/ status queued
    true
  end
  
end
