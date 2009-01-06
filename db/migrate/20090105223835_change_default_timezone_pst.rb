class ChangeDefaultTimezonePst < ActiveRecord::Migration
  def self.up
    change_column :profiles, :time_zone, :string, :default => "PST"
  end

  def self.down
    change_column :profiles, :time_zone, :string, :default => "Pacific Time (US & Canada)"
  end
end
