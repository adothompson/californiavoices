class StoriesController < ApplicationController
  include ApplicationHelper
  before_filter :setup, :except => [:index, :search]
  skip_filter :login_required, :only=>[:index, :search, :show]
  append_before_filter :load_posts, :only => [:show]


  def index
    @stories = Story.find(:all, :order => 'updated_at DESC').paginate(:page => @page, :per_page => @per_page)
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

  def update
  end

  def destroy
  end

  protected

  def load_posts
    @discussion ||= (@story.discussion ||= Discussion.new)

    @posts = Post.paginate(:page => @page, :per_page => @per_page, :order => "created_at ASC", :include => :ratings)
    @post = Post.new
    @show_reply = !@posts.empty? if @show_reply == nil
  end

  private
  
  # TODO : change to fit story searching and ownership
  
  def allow_to
    super :owner, :all => true
    super :all, :only => [:show, :index, :search]
  end
  
  def setup
    @story = Story.find(params[:id]) || nil
  end
  
end
