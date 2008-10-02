class CreateEncodingJobs < ActiveRecord::Migration
  def self.up
    create_table :encoding_jobs do |t|
      t.integer :upload_id, :encoding_profile_id, :video_id, :encoding_time
      t.string :status
      t.text :result
            
      t.timestamps
    end
  end

  def self.down
    drop_table :encoding_jobs
  end
end
