class Discussion < ActiveRecord::Base
  
  ##
  ## associations
  ##

  # don't have pages yet
  # belongs_to :page 
  belongs_to :replied_by, :class_name => 'User'
  belongs_to :last_post, :class_name => 'Post'
  
  # don't have generic profiles yet
  # has_one :profile, :foreign_key => 'discussion_id'

  has_many :posts, :order => 'posts.created_at', :dependent => :destroy, :class_name => 'Post'

  belongs_to :discussable, :polymorphic => true # :commentable, :polymorphic => true
  
  # don't know how to use this yet, think it is for user wall
  # belongs_to :user, :polymorphic => true
  
  ## 
  ## attributes
  ##

  # to help with the create form
  #attr_accessor :body  

  #before_create { |r| r.replied_at = Time.now.utc }
  #after_save    { |r| Post.update_all ['forum_id = ?', r.forum_id], ['topic_id = ?', r.id] }

  ##
  ## methods
  ##

  # def per_page() 30 end
  
  # this doesn't appear to be called anywhere.
  #def paged?() posts_count > per_page end
  
  #   def last_page
  #     if posts_count > 0
  #       (posts_count.to_f / per_page.to_f).ceil
  #     else
  #       1
  #     end
  #   end

end
