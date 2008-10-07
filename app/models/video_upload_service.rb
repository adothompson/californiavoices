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
      end
    rescue
        false
    end
  end
  
  def valid?
    @story.valid? && @upload.valid?
  end  
end
