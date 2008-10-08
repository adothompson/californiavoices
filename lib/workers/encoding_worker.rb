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
    else
      # do encoding and save/upload file
      # encoding.encode
    end
  end
  
  def save_and_upload_original(encoding)
    begin
      encoding_begun = Time.now
      
      # encoding metadata and profile
      video = Video.new encoding.upload.read_metadata
      video.encoding_profile_id = encoding.encoding_profile_id
      video.story_id = encoding.upload.story_id
      # attachement_fu 
      video.filename = encoding.upload.filename
      video.content_type = encoding.upload.content_type
      video.temp_path = encoding.upload.public_filename
      # save video or die
      video.save!
      
      logger.info "#{encoding.id} -- #{Time.now} -- video #{video.id} saved."
      
      # TODO: grab at least one still image to save 
      
      encoding.encoding_time = (Time.now - encoding_begun).to_i
      encoding.video_id = video.id
      encoding.status = 'done'
      encoding.save!
      
      logger.info "#{encoding.id} -- #{Time.now} -- encoding time: #{encoding.encoding_time}."
    rescue
      
      encoding.status = error
      encoding.save!
      
    end
  end
  
end

# encoding statuses [queued, processing, error, done]
