class AddIsActiveToStory < ActiveRecord::Migration
  def self.up
    add_column :stories, :active, :boolean, :default => false    
  end

  def self.down
    remove_column :stories, :active
  end
end
