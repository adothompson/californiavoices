# == Schema Information
# Schema version: 20081003212204
#
# Table name: encoding_profiles
#
#  id                :integer(11)   not null, primary key
#  width             :integer(11)   
#  height            :integer(11)   
#  video_bitrate     :integer(11)   
#  audio_bitrate     :integer(11)   
#  audio_sample_rate :integer(11)   
#  audio_channels    :integer(11)   
#  fps               :integer(11)   
#  position          :integer(11)   
#  name              :string(255)   
#  player            :string(255)   
#  container         :string(255)   
#  video_codec       :string(255)   
#  audio_codec       :string(255)   
#  created_at        :datetime      
#  updated_at        :datetime      
#

class EncodingProfile < ActiveRecord::Base

  has_many :encoding_jobs
  has_many :uploads
  
end
