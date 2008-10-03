# == Schema Information
# Schema version: 20081003212204
#
# Table name: videos
#
#  id                  :integer(11)   not null, primary key
#  story_id            :integer(11)   
#  encoding_profile_id :integer(11)   
#  width               :integer(11)   
#  height              :integer(11)   
#  duration            :integer(11)   
#  encoding_time       :integer(11)   
#  video_bitrate       :integer(11)   
#  audio_bitrate       :integer(11)   
#  audio_sample_rate   :integer(11)   
#  audio_channels      :integer(11)   
#  fps                 :integer(11)   
#  size                :integer(11)   
#  filename            :string(255)   
#  content_type        :string(255)   
#  player              :string(255)   
#  container           :string(255)   
#  video_codec         :string(255)   
#  audio_codec         :string(255)   
#  created_at          :datetime      
#  updated_at          :datetime      
#

class Video < ActiveRecord::Base
  
  # relationships
  belongs_to :story
  belongs_to :encoding_profile
  has_one :encoding_job
  
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
                 :storage => :s3,
                 # :storage => :file_system,
                 :max_size => 300.megabytes
                 )
  validates_as_attachment
  
end
