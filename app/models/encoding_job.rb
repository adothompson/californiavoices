# == Schema Information
# Schema version: 20081003212204
#
# Table name: encoding_jobs
#
#  id                  :integer(11)   not null, primary key
#  upload_id           :integer(11)   
#  encoding_profile_id :integer(11)   
#  video_id            :integer(11)   
#  encoding_time       :integer(11)   
#  status              :string(255)   
#  result              :text          
#  created_at          :datetime      
#  updated_at          :datetime      
#

class EncodingJob < ActiveRecord::Base

  belongs_to :encoding_profile
  belongs_to :upload
  belongs_to :video
  
end
