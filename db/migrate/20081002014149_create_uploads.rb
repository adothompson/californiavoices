class CreateUploads < ActiveRecord::Migration
  def self.up
    create_table :uploads do |t|
      t.integer :story_id, :size, :width, :height, :duration, :video_bitrate, :audio_bitrate, :audio_sample_rate, :audio_channels, :fps
      t.string :filename, :content_type, :container, :video_codec, :audio_codec

      t.timestamps
    end
  end

  def self.down
    drop_table :uploads
  end
end
