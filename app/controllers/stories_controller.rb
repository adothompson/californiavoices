class StoriesController < ApplicationController
  include ApplicationHelper
  before_filter :setup, :only => [:show]
  skip_filter :login_required, :only=>[:index, :show, :search]
  append_before_filter :load_posts, :only => [:show]


  def index
    @topic = Topic.find params[:topic_id] rescue false
    @region = Region.find params[:region_id] rescue false
     
    if @topic
      @stories = @topic.stories.find(:all, :order => 'created_at DESC', :conditions => ['active = true']).paginate(:page => @page, :per_page => @per_page)
    elsif @region
      @stories = @region.stories.find(:all, :order => 'created_at DESC', :conditions => ['active = true']).paginate(:page => @page, :per_page => @per_page)
    else  
      @stories = Story.find(:all, :order => 'created_at DESC', :conditions => ['active = true']).paginate(:page => @page, :per_page => @per_page)
    end
  end

  def search
    @stories = Story.search params[:search], :conditions => {:active => true}, :page => @page, :per_page => @per_page
    render :action => 'index'
  end
  
  def show
    @profile = @story.profile
  end

  def new
    @story = Story.new
    @upload = Upload.new
  end

  def create
    # the story
    @story = Story.new params[:story]
    @story.profile = user.profile
    # the video
    @upload = Upload.new params[:upload]
    # the service story+video
    @service = VideoUploadService.new(@story, @upload)
    
    respond_to do |wants|
      if @service.save
        flash[:notice] = 'Your video was successfully uploaded.  It is in queue for processing.'
        wants.html { redirect_to(@story) }
        wants.xml  { render :xml      => @story,
          :status   => :created,
          :location => @story }
        AuthMailer.deliver_upload(:subject=>"new #{SITE_NAME} story upload",
                                  :body => "title = '#{@story.title}', description = '#{@story.description}'",
                                  :recipients=>REGISTRATION_RECIPIENTS)
      else
        flash[:error] = 'Error: your story could not be saved.'
        wants.html { render :action => :new }
        wants.xml  { render :xml => @story.errors,
          :status => :unprocessable_entity }
      end
    end
  end

  def edit
    render
  end

  protected

  def load_posts
    @discussion ||= (@story.discussion ||= Discussion.new)

    @posts = @discussion.posts.paginate(:page => @page, :per_page => @per_page, :order => "created_at ASC", :include => :ratings)
    @post = Post.new
    @show_reply = !@posts.empty? if @show_reply == nil
  end

  private
  
  # TODO : change to fit story searching and ownership
  
  def allow_to
    # owner of story can do anything? editing?
    super :owner, :all => true
    # approved users can create new stories
    super :user, :only => [:show, :index, :new, :create]
    # everybody can list and watch
    super :all, :only => [:show, :index]
  end
  
  def setup
    @story = Story.find(params[:id]) || nil
  end 
end

class AuthMailer < ActionMailer::Base
  def upload(options)
    self.generic_mailer(options)
  end
end
 
