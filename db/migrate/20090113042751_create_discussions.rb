class CreateDiscussions < ActiveRecord::Migration
  def self.up
    create_table :discussions do |t|
      # from crabgrass discussions
      t.integer  "posts_count",      :limit => 11, :default => 0
      t.datetime "replied_at"
      t.integer  "replied_by_id",    :limit => 11
      t.integer  "last_post_id",     :limit => 11
      t.integer  "page_id",          :limit => 11
      # changed to discussable to avoid overlap with lovd comments for now
      t.integer  "discussable_id",   :limit => 11 # "commentable_id",   :limit => 11
      t.string   "discussable_type"  # "commentable_type"
    end
  end

  def self.down
    drop_table :discussions
  end
end
