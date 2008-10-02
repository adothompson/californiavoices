class CreateEncodingJobs < ActiveRecord::Migration
  def self.up
    create_table :encoding_jobs do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :encoding_jobs
  end
end
