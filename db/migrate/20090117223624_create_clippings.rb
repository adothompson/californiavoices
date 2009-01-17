class CreateClippings < ActiveRecord::Migration
  def self.up
    create_table :clippings do |t|
      t.integer :story_id

      # the following columns are required for attachment_fu
      t.string :content_type, :limit => 100
      t.string :filename, :path, :thumbnail, :limit => 255
      t.integer :parent_id, :size, :width, :height
      t.boolean :preferred, :default => false
       
      t.timestamps
    end
  end

  def self.down
    drop_table :clippings
  end
end
