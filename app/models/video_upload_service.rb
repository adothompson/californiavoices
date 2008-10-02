class VideoUploadService
  
  attr_reader :story, :upload
  
  def initialize(story, upload)
    @story = story
    @upload = upload
  end
  
  def save
    return false unless valid?
    begin
      Story.transaction do
        if @upload.new_record?
          @story.uploads.destroy_all if @story.uploads
          @upload.story = @story
          @upload.save!
        end
        @story.save!
        queue_for_conversion(@upload)
        true
      end
    rescue
        false
    end
  end
  
  def valid?
    @story.valid? && @upload.valid?
  end
  
  protected 
  
  def queue_for_conversion(upload)
    encoding_profiles = EncodingProfile.find(:all, :order => 'position ASC')
    
    encoding_profiles.each do |p|
      job = EncodingJob.new(:upload_id => upload.id, :status => 'queued', encoding_profile_id => p.id)
      job.save!
    end
  end
  
end
