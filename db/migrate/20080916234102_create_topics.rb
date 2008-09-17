class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.string :name, :icon
      t.text :description
      t.integer :stories_count, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :topics
  end
end
