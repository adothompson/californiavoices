class StoriesController < ApplicationController
  include ApplicationHelper
  prepend_before_filter :get_profile, :except => [:index, :search, :show]  
  before_filter :setup, :except => [:index, :search, :show]
  before_filter :search_results, :only => [:index, :search]
  skip_filter :login_required, :only=>[:index, :search, :show]
    
  def index
    # render :action => :search
    @stories = Story.find(:all, :order => 'updated_at DESC').paginate(:page => @page, :per_page => @per_page)
  end
  
  def search
    render
  end

  def show
    @story = Story.find params[:id]
    @profile = @story.profile
    # @comments = @story.comments.paginate(:page => @page, :per_page => @per_page)
    
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

  private
  
  # TODO : change to fit story searching and ownership
  
  def allow_to
    super :owner, :all => true
    super :all, :only => [:show, :index, :search]
  end
  
  def get_profile
    @profile = Profile.find user.profile
  end
  
  def setup
    @user = @profile.user
  end
  
  def search_results
    if params[:search]
      p = params[:search].dup
    else
      p = []
    end
    @results = Story.search((p.delete(:q) || ''), p).paginate(:page => @page, :per_page => @per_page)
  end
  
end
