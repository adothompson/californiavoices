# == Schema Information
# Schema version: 20090115003246
#
# Table name: regions
#
#  id            :integer(4)    not null, primary key
#  name          :string(255)   
#  icon          :string(255)   
#  stories_count :integer(4)    default(0)
#  created_at    :datetime      
#  updated_at    :datetime      
#

class Region < ActiveRecord::Base
  
  has_many :stories
  has_many :locations
  
  # to_param url
  def to_param
    "#{self.id}-#{name.to_safe_uri}"
  end
end
