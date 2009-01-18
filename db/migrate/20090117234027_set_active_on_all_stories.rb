class SetActiveOnAllStories < ActiveRecord::Migration
  def self.up

    Story.find(:all).each do |s|
      s.active = true
      s.save
    end

  end

  def self.down
  end
end
