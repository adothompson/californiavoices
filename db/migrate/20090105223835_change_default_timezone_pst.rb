class ChangeDefaultTimezonePst < ActiveRecord::Migration
  def self.up
    change_column :profiles, :time_zone, :string, :default => "Pacific Time (US & Canada)"
  end

  def self.down
    change_column :profiles, :time_zone, :string, :default => "UTC"
  end
end
