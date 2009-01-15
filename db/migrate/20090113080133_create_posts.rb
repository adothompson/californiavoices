class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.integer  "user_id",       :limit => 11
      t.integer  "discussion_id", :limit => 11
      t.text     "body"
      t.text     "body_html"
      t.string   "type"
      t.datetime "deleted_at"

      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
