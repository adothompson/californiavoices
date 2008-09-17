require 'active_record/fixtures'
class LoadDefaultTopics < ActiveRecord::Migration
  def self.up
    down
    directory = File.join(File.dirname(__FILE__), "data")
    Fixtures.create_fixtures(directory, "topics")
  end

  def self.down
    Topic.delete_all
  end
end
