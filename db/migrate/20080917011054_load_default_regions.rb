require 'active_record/fixtures'
class LoadDefaultRegions < ActiveRecord::Migration
  def self.up
    down
    directory = File.join(File.dirname(__FILE__), "data")
    Fixtures.create_fixtures(directory, "regions")
  end

  def self.down
    Region.delete_all
  end
end
