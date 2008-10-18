# == Schema Information
# Schema version: 20081003212204
#
# Table name: videos
#
#  id                  :integer(4)    not null, primary key
#  story_id            :integer(4)    
#  encoding_profile_id :integer(4)    
#  width               :integer(4)    
#  height              :integer(4)    
#  duration            :integer(4)    
#  encoding_time       :integer(4)    
#  video_bitrate       :integer(4)    
#  audio_bitrate       :integer(4)    
#  audio_sample_rate   :integer(4)    
#  audio_channels      :integer(4)    
#  fps                 :integer(4)    
#  size                :integer(4)    
#  filename            :string(255)   
#  content_type        :string(255)   
#  player              :string(255)   
#  container           :string(255)   
#  video_codec         :string(255)   
#  audio_codec         :string(255)   
#  created_at          :datetime      
#  updated_at          :datetime      
#

class Video < ActiveRecord::Base
  
  # attrs access
  attr_accessible :video_codec, :container, :video_bitrate, :audio_channels, :audio_bitrate, :audio_sample_rate, :audio_codec, :height, :fps, :duration, :width
  
  # relationships
  belongs_to :story
  belongs_to :encoding_profile
  has_one :encoding_job
  
  # mime types:
  # Container => Mime type
  # AVI       => video/x-msvideo
  # WMV       => video/x-ms-wmv
  # FLV       => video/x-flv OR flv-application/octet-stream OR application/octet-stream
  # MPG       => video/mpeg
  # MP3       => audio/mpeg
  # MOV       => video/quicktime
  # MP4       => video/mp4
  
  # attachment_fu params
  has_attachment(:content_type => ['video/x-msvideo','video/x-ms-wmv','video/quicktime','video/mp4','video/x-flv','application/octet-stream','video/mpeg','audio/mpeg'],
                 :storage => :s3,
                 :max_size => 300.megabytes
                 )
  validates_as_attachment

  # Attr Helpers
  
  def embed_html
  end
  
  def embed_js
    return nil unless self.player == 'flash'
    %(
  	<div id="flash_container_#{self.key[0..4]}"><a href="http://www.macromedia.com/go/getflashplayer">Get the latest Flash Player</a> to watch this video.</div>
  	<script type="text/javascript">
      var flashvars = {};
      
      flashvars.file = "#{self.url}";
      flashvars.image = "#{self.clipping.url(:screenshot)}";
      flashvars.width = "#{self.width}";
      flashvars.height = "#{self.height}";
      flashvars.fullscreen = "true";
      flashvars.controlbar = "over";
      #{'flashvars.streamscript = "lighttpd";' if Panda::Config[:videos_store] == :filesystem }
      var params = {wmode:"transparent",allowfullscreen:"true"};
      var attributes = {};
      attributes.align = "top";
      swfobject.embedSWF("#{Store.url('player.swf')}", "flash_container_#{self.key[0..4]}", "#{self.width}", "#{self.height}", "9.0.115", "#{Store.url('expressInstall.swf')}", flashvars, params, attributes);
  	</script>
  	)
  end
  
end
