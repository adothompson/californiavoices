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
    File.join(RAILS_ROOT,'tmp','uploads',"#{self.upload_id}-#{self.encoding_profile_id}-#{self.id}-#{File.basename(self.upload.filename, ".*")}.#{self.container}")
  end
  
  # Encoding
  
  def start_encoding_worker
    worker = MiddleMan.worker(:encoding_worker)
    worker.async_start_next_encoding_job(:job_key => self.id)
    return true
  end
  
  def encode
    begun_encoding = Time.now
    
    begin
      logger.info "(#{Time.now.to_s}) Encoding #{self.id}"
      
      if self.container == "flv" and self.player == "flash"
        self.encode_flv_flash
      elsif self.container == 'mp3'and self.player == nil
        self.encode_mp3
      else # Try straight ffmpeg encode
        self.encode_unknown_format
      end
      
      self.status = "success"
      self.encoded_at = Time.now
      self.encoding_time = (Time.now - begun_encoding).to_i
      self.save

      logger.info "Removing tmp video files"
      
      logger.info "Encoding successful"
    rescue
      self.status = "error"
      self.save
      
      logger.error "Unable to transcode file #{self.id}: #{$!.class} - #{$!.message}"
      
      raise
    end
  end

  def encode_flv_flash
    logger.info "Encoding with encode_flv_flash"
    transcoder = RVideo::Transcoder.new
    recipe = "ffmpeg -i $input_file$ -r $fps$ -b $video_bitrate$k -acodec $audio_codec$ -ab $audio_bitrate$k -ar $audio_sample_rate$ -ac $audio_channels$ $resolution_and_padding$ -f $container$ -y $output_file$"
    recipe += "\nflvtool2 -U $output_file$"
    transcoder.execute(recipe, self.recipe_options(self.upload.tmp_filepath, self.tmp_filepath))
  end
  
  def encode_unknown_format
    logger.info "Encoding with encode_unknown_format"
    transcoder = RVideo::Transcoder.new
    recipe = "ffmpeg -i $input_file$ -f $container$ -vcodec $video_codec$ -b $video_bitrate_in_bits$ -ar $audio_sample_rate$ -ab $audio_bitrate$k -acodec $audio_codec$ -r 24 $resolution_and_padding$ -y $output_file$"
    logger.info "Unknown encoding format given but trying to encode anyway."
    transcoder.execute(recipe, recipe_options(self.upload.tmp_filepath, self.tmp_filepath))
  end
  
  def recipe_options(input_file, output_file)
    profile = self.encoding_profile

    {
      :input_file => input_file,
      :output_file => output_file,
      :container => profile.container, 
      :video_codec => (profile.video_codec rescue nil),
      :video_bitrate => profile.video_bitrate.to_s, 
      :fps => (profile.fps.to_s rescue nil),
      :audio_codec => profile.audio_codec, 
      :audio_bitrate => profile.audio_bitrate.to_s,
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
      Merb.logger.error "Couldn't do w/h to caculate aspect. Just using the output resolution now."
      return %(-s #{self.width}x#{self.height} )
    end

    height = (out_w / aspect.to_f).to_i
    height -= 1 if height % 2 == 1

    opts_string = %(-s #{self.width}x#{height} )

    # Keep the video's original width if the height
    if height > out_h
      width = (out_h / aspect_inv.to_f).to_i
      width -= 1 if width % 2 == 1

      opts_string = %(-s #{width}x#{self.height} )
      self.width = width
      self.save
    # Otherwise letterbox it
    elsif height < out_h
      pad = ((out_h - height.to_f) / 2.0).to_i
      pad -= 1 if pad % 2 == 1
      opts_string += %(-padtop #{pad} -padbottom #{pad})
    end

    return opts_string
  end  
  
end
