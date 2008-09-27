class Story < ActiveRecord::Base

  #TODO: add acts_as_taggable??
  
  # relationships
  has_many :videos
  belongs_to :profile # or user? (maybe group profile)
  belongs_to :topic
  belongs_to :region
  has_many :comments, :as => :commentable, :order => "created_at asc"
  validates_presence_of :title, :description, :topic_id, :region_id

  #TODO: after create for update feed items
#   def after_create
#     feed_item = FeedItem.create(:item => self)
#     ([profile] + profile.friends + profile.followers).each{ |p| p.feed_items << feed_item }
#   end
  
  def to_param
    "#{self.id}-#{title.to_safe_uri}"
  end

end
