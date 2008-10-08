class QueueWorker < BackgrounDRb::MetaWorker
  set_worker_name :queue_worker
  
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
    
    add_periodic_timer(10) { check_encoding_queue }
    
  end
  
  def check_encoding_queue
    
    if EncodingJob.processing?
      logger.info "-- #{Time.now} -- there is something in the processing queue."
      # -- is that processing taking too long? updated_at field should be within 40min?
    else
      # if no processing is happening
      # -- find the next job, change it's status to processing
      logger.info "-- #{Time.now} -- nothing in processing queue."
      
      # set encoding to 'processing'
      e = EncodingJob.next_job
      e.status = 'processing'
      e.save!
      
      e.start_encoding_worker  
    end
    
    return true
  end

end

