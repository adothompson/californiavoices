# == Schema Information
# Schema version: 20090115003246
#
# Table name: videos
#
#  id                  :integer(4)    not null, primary key
#  story_id            :integer(4)    
#  encoding_profile_id :integer(4)    
#  width               :integer(4)    
#  height              :integer(4)    
#  duration            :integer(4)    
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
  # ============
  
  def embed_html
    return nil unless self.player == 'flash'
    %(<embed src="http://#{SITE}/swf/player.swf" width="420" height="315" allowfullscreen="true" allowscriptaccess="always" flashvars="file=#{self.public_filename}&logo=http://#{SITE}/images/cavoices-logo-sm.png&controlbar=over"/>)
  end

  # TODO: image overlay for preview
  # ie &image=#{self.story.preview_image ? self.story.preview_image.public_filename(:preview) : ''}
  def embed_js
    return nil unless self.player == 'flash'
    %(
  	<div id="player_#{self.id}"><a href="http://www.macromedia.com/go/getflashplayer">#{self.embed_html}</a></div>

  	<script type="text/javascript">
          var so = new SWFObject('http://#{SITE}/swf/player.swf','mpl','420','315','9');
          so.addParam('allowscriptaccess','always');
          so.addParam('allowfullscreen','true');
          so.addParam('flashvars','&file=#{self.public_filename}&logo=http://#{SITE}/images/cavoices-logo-sm.png&controlbar=over');
          so.write('player_#{self.id}');
        </script>
  	)
  end  
end
