# == Schema Information
# Schema version: 20081003212204
#
# Table name: encoding_profiles
#
#  id                :integer(4)    not null, primary key
#  width             :integer(4)    
#  height            :integer(4)    
#  video_bitrate     :integer(4)    
#  audio_bitrate     :integer(4)    
#  audio_sample_rate :integer(4)    
#  audio_channels    :integer(4)    
#  fps               :integer(4)    
#  position          :integer(4)    
#  name              :string(255)   
#  player            :string(255)   
#  container         :string(255)   
#  video_codec       :string(255)   
#  audio_codec       :string(255)   
#  created_at        :datetime      
#  updated_at        :datetime      
#

class EncodingProfile < ActiveRecord::Base

  has_many :videos
  
end
