class AddUploadIdToStory < ActiveRecord::Migration
  def self.up
    add_column :stories, :upload_id, :integer
  end

  def self.down
    remove_column :stories, :upload_id
  end
end
