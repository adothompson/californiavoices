class CreateVideos < ActiveRecord::Migration
  def self.up
    create_table :videos do |t|
      t.integer :story_id, :encoding_profile_id, :width, :height, :duration, :encoding_time, :video_bitrate, :audio_bitrate, :audio_sample_rate, :audio_channels, :fps, :size
      t.string :filename, :content_type, :player, :container, :video_codec, :audio_codec
      
      t.timestamps
    end
  end

  def self.down
    drop_table :videos
  end
end
