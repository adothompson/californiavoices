module HomeHelper
  
  def newest_pictures limit = 12
    Photo.find(:all, :order => 'created_at desc', :limit => limit)
  end
  
  def recent_comments limit = 10
    Comment.find(:all, :order => 'created_at desc', :limit => limit, :conditions => "commentable_type='Profile'")
  end
  
  def new_members(limit = 14)
    Profile.find(:all, :limit => limit, :order => 'created_at DESC', :conditions=>"user_id is not null AND is_active = TRUE")
  end
  
  def new_stories(limit = 14)
    Story.find(:all, :limit => limit, :order => 'created_at DESC') # TODO: set condition for finished processing
  end
  
#   def recent_forum_posts(limit = 10)
#     ForumTopic.find(:all, :limit => limit, :order => 'forum_posts.created_at DESC', :include => [:forum, :posts])
#   end
  
end
