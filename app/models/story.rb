# == Schema Information
# Schema version: 20090115003246
#
# Table name: stories
#
#  id          :integer(4)    not null, primary key
#  title       :string(255)   
#  description :text          
#  profile_id  :integer(4)    
#  topic_id    :integer(4)    
#  region_id   :integer(4)    
#  created_at  :datetime      
#  updated_at  :datetime      
#

class Story < ActiveRecord::Base

  #TODO: add acts_as_taggable?? or acts_as_taggable_on

  profanity_filter! :title, :description
  
  # basic relationships
  has_many :videos, :dependent => :destroy
  has_many :uploads, :dependent => :destroy
  has_many :clippings, :dependent => :destroy, :order => 'preferred DESC'
  belongs_to :profile
  belongs_to :topic
  belongs_to :region

  # discussion relationship
  has_one :discussion, :as => :discussable, :dependent => :destroy
  
  def topic_name
    self.topic.name
  end
  
  def region_name
    self.region.name
  end
    
  # validations
  validates_presence_of :title, :description, :topic_id, :region_id, :profile_id

  # feed item for profiles
  def after_create
    feed_item = FeedItem.create(:item => self)
    ([profile] + profile.friends + profile.followers).each{ |p| p.feed_items << feed_item }
  end
  
  # story url
  def to_param
    "#{self.id}-#{title.to_safe_uri}"
  end
    
  # comments
  has_many :comments, :as => :commentable, :order => "created_at asc"
  
  def self.search query = '', options = {}
    query ||= ''
    q = '*' + query.gsub(/[^\w\s-]/, '').gsub(' ', '* *') + '*'
    options.each {|key, value| q += " #{key}:#{value}"}
    arr = find_by_contents q, :limit=>:all
    logger.debug arr.inspect
    arr
  end

  # finders and attr helpers

  def preview_image
    self.clippings.first || false
  end
  
  def flash_low
    self.videos.find(:first, :conditions => ['encoding_profile_id = ?', 2])
  end

  def flash_sd
    self.videos.find(:first, :conditions => ['encoding_profile_id = ?', 3]) || self.flash_low
  end

  def icon 
    # get image clipping icon
    "http://#{SITE}/images/video_icon_small.jpg"
  end
  
end
