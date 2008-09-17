class CreateRegions < ActiveRecord::Migration
  def self.up
    create_table :regions do |t|
      t.string :name, :icon
      t.integer :stories_count, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :regions
  end
end
