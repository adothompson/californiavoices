class CreateEncodingProfiles < ActiveRecord::Migration
  def self.up
    create_table :encoding_profiles do |t|
      t.integer :width, :height, :video_bitrate, :audio_bitrate, :audio_sample_rate, :audio_channels, :fps, :position
      t.string :name, :player, :container, :video_codec, :audio_codec
      t.timestamps
    end
  end

  def self.down
    drop_table :encoding_profiles
  end
end
