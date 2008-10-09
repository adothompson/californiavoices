# == Schema Information
# Schema version: 20081003212204
#
# Table name: uploads
#
#  id           :integer(4)    not null, primary key
#  story_id     :integer(4)    
#  size         :integer(4)    
#  filename     :string(255)   
#  content_type :string(255)   
#  created_at   :datetime      
#  updated_at   :datetime      
#

require 'rvideo'

class Upload < ActiveRecord::Base

  # attrs access
  attr_accessible :video_codec, :container, :video_bitrate, :audio_channels, :audio_bitrate, :audio_sample_rate, :audio_codec, :height, :fps, :duration, :width
  
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
  has_attachment(:content_type => ['video/x-msvideo','video/x-ms-wmv','video/quicktime','video/mp4','video/x-flv','flv-application/octet-stream','video/mpeg'],
                 :storage => :file_system,
                 :path_prefix => 'tmp/uploads',
                 :max_size => 300.megabytes
                 )
  validates_as_attachment
  
  # after create run process?
  after_create do |upload|
    logger.info "\n\n-- #{self.id} -- CAVOICES - #{upload.filename} uploaded.\n\n"
    upload.process
  end
    
  # Uploads --------------
    
  def process
    logger.info "\n\n-- #{self.id} -- CAVOICES - process started on #{self.filename}.\n\n"
    self.read_and_save_metadata
    self.add_to_queue
  end
  
  def read_and_save_metadata
    logger.info "\n\n# #{self.id} #CAVOICES - reading metadata for #{self.public_filename}.\n\n"
    
    # check if public_filename is exists else use temp_path
    
    if File.exist?(self.public_filename)
      inspector = RVideo::Inspector.new(:file => self.public_filename)
    elsif File.exist?(self.temp_path)
      inspector = RVideo::Inspector.new(:file => self.temp_path)
    else
      raise NoFileSubmitted
    end
        
    raise FormatNotRecognised unless inspector.valid? and inspector.video?
            
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
    
    logger.info "\n\n #{upload_metadata.to_yaml} \n\n"

    self.update_attributes upload_metadata
  end
      
  def add_to_queue
    logger.info "\n\n-- #{self.id} -- CAVOICES - adding to queue for #{self.filename}.\n\n"
    # for each encoding profile create an encodingjob w/ status queued
    
    # Die if there's no profiles!
    if EncodingProfile.find(:all).empty?
      logger.info "\n\n-- #{self.id} -- CAVOICES - There are no encoding profiles!\n\n"
      return nil
    end

    # TODO: Allow manual selection of encoding profiles used in both form and api
    # For now we will just encode to all available profiles
    logger.info "\n\n-- #{self.id} -- CAVOICES - looping profiles #{self.filename}.\n\n"
    EncodingProfile.find(:all).each do |p|
      unless self.find_encoding_for_profile(p)
        logger.info "\n\n-- #{self.id} -- CAVOICES - did not find profile, time to create.\n\n"
        self.create_encoding_for_profile(p)
      end
    end
    return true
  end
  
  def create_encoding_for_profile(p)
    logger.info "\n\n-- #{self.id} -- CAVOICES - creating profile for #{self.filename} - #{p.name}.\n\n"

    encoding = EncodingJob.new
    encoding.status = 'queued'
    
    encoding.upload_id = self.id
    encoding.encoding_profile_id = p.id
    
    encoding.save
    return encoding    
  end

  # Finders
  
  def find_encoding_for_profile(p)
    logger.info "\n\n-- #{self.id} -- CAVOICES - find encoding profile for #{self.filename}.\n\n"

    e = EncodingJob.find(:first, :conditions => ["upload_id = ? AND encoding_profile_id = ?", self.id, p.id]) ? true : false
    
    logger.info "\n\n-- #{self.id} -- CAVOICES - #{e}"
    
    return e
  end
  
  # Attr Helpers
  
  def read_metadata
    {
      :width => (self.width rescue nil), 
      :height => (self.height rescue nil), 
      :duration => (self.duration rescue nil), 
      :container => (self.container rescue nil), 
      :video_codec => (self.video_codec rescue nil), 
      :video_bitrate => (self.bitrate rescue nil),
      :fps => (self.fps rescue nil), 
      :audio_codec => (self.audio_codec rescue nil), 
      :audio_sample_rate => (self.audio_sample_rate rescue nil),
      :audio_bitrate => (self.audio_bitrate rescue nil), 
      :audio_channels => (self.audio_channels rescue nil)
    }
  end
  
  # Exceptions
  
  class VideoError < StandardError; end
  #class NotificationError < StandardError; end
  
  # 404
  # TODO: not valid error in upload controller (stories?)
  # class NotValid < VideoError; end
  
  # 500
  # TODO: no file submitted check should happen in upload controller (stories)
  class NoFileSubmitted < VideoError; end
  class FormatNotRecognised < VideoError; end
  
end
