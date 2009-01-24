# == Schema Information
# Schema version: 20090115003246
#
# Table name: locations
#
#  id         :integer(4)    not null, primary key
#  name       :string(255)   
#  street     :string(255)   
#  city       :string(255)   
#  state      :string(255)   
#  zip_code   :string(255)   
#  lat        :string(255)   
#  lng        :string(255)   
#  region_id  :integer(4)    
#  created_at :datetime      
#  updated_at :datetime      
#

class Location < ActiveRecord::Base

  # validations
  # validates_uniqueness_of :name # unique name for searching 
  validates_format_of :zip_code, :with => %r{\d{5}(-\d{4})?}, :message => "should be 12345 or 12345-1234"

  # relationships
  has_many :profiles, :dependent => :nullify
  belongs_to :region

end
