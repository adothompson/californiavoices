# required to use ActionController::TestUploadedFile 
require 'action_controller'
require 'action_controller/test_process.rb'

class EncodingWorker < BackgrounDRb::MetaWorker
  set_worker_name :encoding_worker
  #set_no_auto_load(true)  
  
  def create(args = nil)
    # this method is called, when worker is loaded for the first time        
  end
  
  def start_next_encoding_job
    encoding = EncodingJob.current_encoding

    logger.info "#{encoding.id} -- #{Time.now} -- encoding #{encoding.encoding_profile.name} begun."

    if encoding.encoding_profile.name == 'Original'
      # save and upload original
      save_and_upload_original(encoding)
      return true
    else
      # do encoding and save/upload file
      # encoding.encode
      return true
    end
  end
  
  def save_and_upload_original(e)
    begin
      encoding_begun = Time.now
      
      # encoding metadata and profile
      v = Video.new(:uploaded_data => ActionController::TestUploadedFile.new(e.upload.public_filename, e.upload.content_type))
      v.encoding_profile_id = e.encoding_profile_id
      v.story_id = e.upload.story_id
      v.update_attributes e.upload.read_metadata
      # save video or die
      v.save!
      
      logger.info "#{e.id} -- #{Time.now} -- video #{v.id} saved."
      
      # TODO: grab at least one still image to save 
      
      e.encoding_time = (Time.now - encoding_begun).to_i
      e.video_id = v.id
      e.status = 'done'
      e.save!
      
      logger.info "#{e.id} -- #{Time.now} -- encoding time: #{e.encoding_time}."
    rescue
      
      e.status = 'error'
      logger.info "#{e.id} -- #{Time.now} -- Error - #{$!.class} - #{$!.message}"
      e.save!
    end
  end
  
end

# encoding statuses [queued, processing, error, done]
