class LoadDefaultEncodingProfiles < ActiveRecord::Migration
  def self.up
    
    #NOTE: some help from http://www.adobe.com/devnet/flash/articles/encoding_video_04.html
    
    # Flash Video LOW
    Profile.create!( :title => 'Flash Video LOW', :container => 'flv', :video_bitrate => 200, :audio_bitrate => 32, 
                     :video_codec => nil, :audio_codec => 'libmp3lame', :audio_sample_rate => 22050, 
                     :audio_channels => 1, :width => 320, :height => 240, :fps => 15, :position => 0, :player => 'flash'
                     )
    # ffmpeg -i test.avi -r 15 -b 200k -acodec libmp3lame -ab 32k -ar 22050 -ac 1 -s 320x240 -f flv -y test.flv
    
    # Flash Video SD
    Profile.create!( :title => 'Flash Video SD', :container => 'flv', :video_bitrate => 300, :audio_bitrate => 48, 
                     :video_codec => nil, :audio_codec => 'libmp3lame', :audio_sample_rate => 22050, 
                     :audio_channels => 1, :width => 480, :height => 360, :fps => 24, :position => 1, :player => 'flash'
                     )
    # ffmpeg -i test.avi -r 24 -b 300k -acodec libmp3lame -ab 48k -ar 22050 -ac 1 -s 480x360 -f flv -y test.flv

    # MP4 Standard
    Profile.create!( :title => "MP4 SD", :container => "mp4",  :video_bitrate => 300, :audio_bitrate => 48, 
                     :video_codec => "mpeg4", :audio_codec => "libfaac", :audio_sample_rate => 44100, 
                     :audio_channels => 1, :width => 320, :height => 240, :fps => 24, :position => 2, :player => nil)
    # ffmpeg -i test.avi -r 24 -b 300k -acodec libfaac -ab 48k -ar 44100 -ac 1 -vcodec mpeg4 -s 320x240 -f mp4 -y test.mp4
    
    # MP3 Standard
    Profile.create!( :title => "MP3 SD", :container => "mp3",  :video_bitrate => nil, :audio_bitrate => 48, 
                     :video_codec => nil, :audio_codec => "libmp3lame", :audio_sample_rate => 44100, 
                     :audio_channels => 1, :width => nil, :height => nil, :fps => nil, :position => 3, :player => nil)
    # ffmpeg -i test.avi -vn -acodec libmp3lame -ab 48k -ar 44100 -ac 1 -f mp3 -y test.mp3
    
    
    # Flash Video HI
     Profile.create!( :title => 'Flash Video HI', :container => 'flv', :video_bitrate => 400, :audio_bitrate => 96, 
                     :video_codec => nil, :audio_codec => 'libmp3lame', :audio_sample_rate => 44100, 
                     :audio_channels => 2, :width => 640, :height => 480, :fps => 24, :position => 4, :player => 'flash'
                     )
    # ffmpeg -i test.avi -r 24 -b 400k -acodec libmp3lame -ab 96k -ar 44100 -ac 2 -s 640x480 -f flv -y test.flv
   
    # Flash h264 SD
#     Profile.create!( :title => 'Flash h264 SD', :container => 'mp4', :video_bitrate => 300, :audio_bitrate => 48, 
#                      :video_codec => 'libx264', :audio_codec => 'faac', :audio_sample_rate => '44100', 
#                      :audio_channels => 1, :width => 320, :height => 240, :fps => 24, :position => 5, :player => 'flash'
#                      )
    # ffmpeg -i test.avi -r 24 -b 300k -vcodec libx264 -acodec libfaac -ab 48k -ar 44100 -ac 1 -s 320x240 -f mp4 -y test.mp4
    
    # Flash h264 HI
#     Profile.create!( :title => 'Flash h264 HI', :container => 'mp4', :video_bitrate => 400, :audio_bitrate => 64, 
#                      :video_codec => 'x264', :audio_codec => 'faac', :audio_sample_rate => '44100', 
#                      :audio_channels => 2, :width => 480, :height => 360, :fps => 24, :position => 6, :player => 'flash'
#                      )
    
    # Flash h264 480p
#     Profile.create!( :title => 'Flash h264 480p', :container => 'mp4', :video_bitrate => 600, :audio_bitrate => 96, 
#                      :video_codec => 'x264', :audio_codec => 'faac', :audio_sample_rate => '44100', 
#                      :audio_channels => 2, :width => 852, :height => 480, :fps => 24, :position => 7, :player => 'flash'
#                      )
  end

  def self.down
    Profile.delete_all
  end
end
