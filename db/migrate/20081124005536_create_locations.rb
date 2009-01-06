class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.string :name, :street, :city, :state, :zip_code
      t.string :lat, :lng
      t.timestamps
    end
    add_column :profiles, :location_id, :integer
    rename_column :profiles, :location, :location_cache
    add_index :locations, :name, :unique => true
  end

  def self.down
    drop_table :locations
    remove_column :profiles, :location_id
    rename_column :profiles, :location_cache, :location
    remove_index :locations, :name
  end
end
