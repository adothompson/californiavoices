class QueueWorker < BackgrounDRb::MetaWorker
  set_worker_name :queue_worker
  
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
    
    # TODO: increase timer to several minutes (3-5?)
    add_periodic_timer(300) { check_encoding_queue }
    
#     while true do
#       logger.info "going again"
#       check_encoding_queue
#       sleep(10)
#     end
    
  end
  
  def check_encoding_queue
    logger.info "did we get to queue thing. #{EncodingJob.processing?} - #{EncodingJob.current_encoding}"

    begin
      if EncodingJob.processing?
        current_encoding = EncodingJob.current_encoding
        processing_time = (Time.now - e.updated_at).to_i / 60 # minutes since status was updated to processing
        logger.info "-- #{Time.now} -- there is something in the processing queue (started #{processing_time} minutes ago)."
        
        # -- is that processing taking too long? updated_at field should be within 40min?
        if processing_time > 40
          logger.info "-- #{Time.now} -- the encoding (started #{processing_time} minutes ago) is taking too long and will be ended.."
          current_encoding.status = 'error'
          current_encoding.result = 'processing took too long.'
          current_encoding.save!
        end
        
      else
        # if no processing is happening
        # -- find the next job, change it's status to processing
        logger.info "-- #{Time.now} -- nothing in processing queue."
        
        # set encoding to 'processing'
        if e = EncodingJob.next_job
          e.status = 'processing'
          e.save!
          
          e.start_encoding_worker  
        end
      end
    rescue
      return nil
    end
  end

end

