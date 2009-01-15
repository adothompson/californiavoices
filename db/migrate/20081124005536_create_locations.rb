class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.string :name, :street, :city, :state, :zip_code
      t.string :lat, :lng
      t.integer :region_id
      t.timestamps
    end
    add_column :profiles, :location_id, :integer
    rename_column :profiles, :location, :location_name
  end

  def self.down
    drop_table :locations
    remove_column :profiles, :location_id
    rename_column :profiles, :location_name, :location
  end
end
