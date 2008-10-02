class VideoUploadService
  
  attr_reader :story, :video
  
  def initialize(story, video)
    @story = story
    @video = video
  end
  
  def save
    return false unless valid?
    begin
      Story.transaction do
        if @video.new_record?
          @story.videos.destroy_all if @story.videos
          @video.story = @story
          @video.save!
        end
        @story.save!
        queue_for_conversion(@video)
        true
      end
    rescue
        false
    end
  end
  
  def valid?
    @story.valid? && @video.valid?
  end
  
  protected 
  
  def queue_for_conversion(video)
    # check for existing worker?
    ## send to worker if existing
    # create new worker otherwise
    # TODO: create backgroundrb worker to handle queue (autostart = true)
    # TODO: queue worker passes of to conversion worker
  end
  
#   def start_conversion_worker(video_file)
#     # new backgroundrb start
#     MiddleMan.new_worker(:worker => :voices_worker, :job_key => video_file.id, :data => video_file.id)
#   end

end
