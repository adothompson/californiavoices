# == Schema Information
# Schema version: 20080917012917
#
# Table name: photos
#
#  id         :integer(11)   not null, primary key
#  caption    :string(1000)  
#  created_at :datetime      
#  updated_at :datetime      
#  profile_id :integer(11)   
#  image      :string(255)   
#


class Photo < ActiveRecord::Base
  
  has_many :comments, :as => :commentable, :dependent => :destroy, :order => 'created_at ASC'
  
  belongs_to :profile
  
  validates_presence_of :image, :profile_id
  attr_immutable :id, :profile_id
  
  def after_create
    feed_item = FeedItem.create(:item => self)
    ([profile] + profile.friends + profile.followers).each{ |p| p.feed_items << feed_item }
  end

  file_column :image, :magick => {
    :versions => { 
      :square => {:crop => "1:1", :size => "50x50", :name => "square"},
      :small => "175x250>"
    }
  }
    
end
