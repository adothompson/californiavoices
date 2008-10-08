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

require 'rvideo'

class EncodingJob < ActiveRecord::Base

  # relationships
  belongs_to :upload
  belongs_to :video
  belongs_to :encoding_profile
    
  # Finders
  
  # find if anything is processing
  def self.processing?
    find(:all, :conditions => ["status = ?", 'processing']).first ? true : false
  end
  
  # what is the current encoding job
  def self.current_encoding
    find(:all, :conditions => ["status = ?", 'processing']).first || false
  end
  
  # find next encoding job from queue
  def self.next_job
    find(:all, :conditions => ["status = ?", 'queued'], :order => 'created_at ASC').first || false
  end
  
  # Encoding
  
  def start_encoding_worker
    worker = MiddleMan.worker(:encoding_worker)
    worker.async_start_next_encoding_job(:job_key => self.id)
    true
  end
  
  
  
end
