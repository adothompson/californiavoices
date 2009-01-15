require 'active_record/fixtures'
class LoadDefaultLocations < ActiveRecord::Migration
  def self.up
    down
    directory = File.join(File.dirname(__FILE__), "data")
    Fixtures.create_fixtures(directory, "locations")
  end

  def self.down
    Location.delete_all
  end
end
