# == Schema Information
# Schema version: 20081003212204
#
# Table name: encoding_jobs
#
#  id                  :integer(4)    not null, primary key
#  upload_id           :integer(4)    
#  encoding_profile_id :integer(4)    
#  video_id            :integer(4)    
#  encoding_time       :integer(4)    
#  status              :string(255)   
#  result              :text          
#  created_at          :datetime      
#  updated_at          :datetime      
#

require 'rvideo'
require 'action_controller'
require 'action_controller/test_process.rb'

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
  
  # Attr Helpers
  
  def container
    self.encoding_profile.container
  end
  
  def profile
    self.encoding_profile.name
  end
  
  def tmp_filepath
    File.join(File.dirname(self.upload.public_filename),"#{self.upload_id}-#{self.encoding_profile_id}-#{self.id}-#{File.basename(self.upload.filename, ".*")}.#{self.container}")
  end

  def tmp_mimetype
    mimetype = `file -ib #{self.tmp_filepath}`.gsub(/\n/,"")
  end
  
  # Encoding
  
  def start_encoding_worker
    worker = MiddleMan.worker(:encoding_worker)
    worker.async_start_next_encoding_job(:job_key => self.id)
  end
  
  def encode
    begun_encoding = Time.now
    
    begin
      logger.info "#{self.id} -- #{Time.now} -- encoding #{self.encoding_profile.name} begun."
      
      if self.encoding_profile.container == "flv" and self.encoding_profile.player == "flash"
        self.encode_flv_flash
      elsif self.container == 'mp4'and self.encoding_profile.player == nil
        self.encode_mp4
      elsif self.container == 'mp3'and self.encoding_profile.player == nil
        self.encode_mp3
      else # Try straight ffmpeg encode
        self.encode_unknown_format
      end

      # save video object - 
      
      v = Video.new(:uploaded_data => ActionController::TestUploadedFile.new(self.tmp_filepath, self.tmp_mimetype))
      v.encoding_profile_id = self.encoding_profile_id
      v.story_id = self.upload.story_id
      v.update_attributes self.upload.read_metadata
      v.player = self.encoding_profile.player || nil
      # save video or die
      v.save!
      
      logger.info "#{self.id} -- #{Time.now} -- video #{v.id} saved."
      
      # TODO: grab at least one still image to save 
      self.video_id = v.id
           
      self.status = "success"
      self.encoding_time = (Time.now - begun_encoding).to_i
      self.save

      logger.info "#{self.id} -- #{Time.now} -- Removing tmp video files"
      
      # TODO: actually remove temp files from encoding
      
      logger.info "#{self.id} -- #{Time.now} -- Encoding successful"
    rescue RVideo::TranscoderError => e
      self.status = "error"
      self.save
      
      logger.error "#{self.id} -- #{Time.now} -- Unable to transcode file #{self.id}: #{$!.class} - #{$!.message}"
      
      #raise
    rescue
      self.status = "error"
      self.save
      
      logger.error "#{self.id} -- #{Time.now} -- Unable to transcode file #{self.id}: #{$!.class} - #{$!.message}"      
    end
  end

  def encode_flv_flash
    logger.info "#{self.id} -- #{Time.now} -- encoding #{self.encoding_profile.name} w/ encode_flv_flash."
    transcoder = RVideo::Transcoder.new
    recipe = "ffmpeg -i $input_file$ -r #{self.encoding_profile.fps} -b $video_bitrate$ -acodec $audio_codec$ -ab $audio_bitrate$ -ar $audio_sample_rate$ -ac $audio_channels$ $resolution_and_padding$ -f $container$ -y $output_file$"
    recipe += "\nflvtool2 -U $output_file$"
    transcoder.execute(recipe, self.recipe_options(self.upload.public_filename, self.tmp_filepath))
    logger.info "#{self.id} -- #{Time.now} -- \n #{transcoder.processed.to_yaml}"
  end

  def encode_mp4
    # ffmpeg -i test.avi -r 24 -b 300k -acodec libfaac -ab 48k -ar 44100 -ac 1 -vcodec mpeg4 -s 320x240 -f mp4 -y test.mp4
    logger.info "#{self.id} -- #{Time.now} -- encoding #{self.encoding_profile.name} w/ encode_mp4."
    transcoder = RVideo::Transcoder.new
    recipe = "ffmpeg -i $input_file$ -r #{self.encoding_profile.fps} -b $video_bitrate$ -acodec $audio_codec$ -ab $audio_bitrate$ -ar $audio_sample_rate$ -ac $audio_channels$ -vcodec $video_codec$ $resolution_and_padding$ -f $container$ -y $output_file$"
    transcoder.execute(recipe, self.recipe_options(self.upload.public_filename, self.tmp_filepath))
    logger.info "#{self.id} -- #{Time.now} -- \n #{transcoder.processed.to_yaml}"
  end  
  
  def encode_mp3
    # ffmpeg -i test.avi -vn -acodec libmp3lame -ab 48k -ar 44100 -ac 1 -f mp3 -y test.mp3
    logger.info "#{self.id} -- #{Time.now} -- encoding #{self.encoding_profile.name} w/ encode_mp3."
    transcoder = RVideo::Transcoder.new
    recipe = "ffmpeg -i $input_file$ -vn -acodec $audio_codec$ -ab $audio_bitrate$ -ar $audio_sample_rate$ -ac $audio_channels$ -f $container$ -y $output_file$"
    transcoder.execute(recipe, self.recipe_options(self.upload.public_filename, self.tmp_filepath))
    logger.info "#{self.id} -- #{Time.now} -- \n #{transcoder.processed.to_yaml}"
  end  
  
  def encode_unknown_format
    logger.info "Encoding with encode_unknown_format"
    transcoder = RVideo::Transcoder.new
    recipe = "ffmpeg -i $input_file$ -r 24 -f $container$ -vcodec $video_codec$ -b $video_bitrate_in_bits$ -ar $audio_sample_rate$ -ab $audio_bitrate$k -acodec $audio_codec$ -r 24 $resolution_and_padding$ -y $output_file$"
    logger.info "Unknown encoding format given but trying to encode anyway."
    transcoder.execute(recipe, recipe_options(self.upload.tmp_filepath, self.tmp_filepath))
  end
  
  def recipe_options(input_file, output_file)
    profile = self.encoding_profile

    {
      :input_file => input_file,
      :output_file => output_file,
      :container => profile.container, 
      :video_codec => profile.video_codec,
      :video_bitrate => profile.video_bitrate.to_s + "K", 
      :fps => profile.fps.to_s, # FIXME: weird error doesn't like FPS being sent
      :audio_codec => profile.audio_codec, 
      :audio_bitrate => profile.audio_bitrate.to_s + "K",
      :audio_sample_rate => profile.audio_sample_rate.to_s,
      :audio_channels => profile.audio_channels.to_s,
      :resolution_and_padding => self.ffmpeg_resolution_and_padding_no_cropping
    }
  end
  
  def ffmpeg_resolution_and_padding_no_cropping
    # Calculate resolution and any padding
    in_w = self.upload.width.to_f
    in_h = self.upload.height.to_f
    out_w = self.encoding_profile.width.to_f
    out_h = self.encoding_profile.height.to_f

    begin
      aspect = in_w / in_h
      aspect_inv = in_h / in_w
    rescue
      logger.error "Couldn't do w/h to caculate aspect. Just using the output resolution now."
      return %(-s #{self.encoding_profile.width}x#{self.encoding_profile.height} )
    end

    height = (out_w / aspect.to_f).to_i
    height -= 1 if height % 2 == 1

    opts_string = %(-s #{self.encoding_profile.width}x#{height} )

    # Keep the video's original width if the height
    if height > out_h
      width = (out_h / aspect_inv.to_f).to_i
      width -= 1 if width % 2 == 1

      opts_string = %(-s #{width}x#{self.encoding_profile.height} )

    # Otherwise letterbox it
    elsif height < out_h
      pad = ((out_h - height.to_f) / 2.0).to_i
      pad -= 1 if pad % 2 == 1
      opts_string += %(-padtop #{pad} -padbottom #{pad})
    end

    return opts_string
  end  
  
end
