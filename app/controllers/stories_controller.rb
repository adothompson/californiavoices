class StoriesController < ApplicationController
  include ApplicationHelper
  prepend_before_filter :get_profile, :except => [:new, :create, :index, :search]  
  before_filter :setup, :except => [:index, :search]
  before_filter :search_results, :only => [:index, :search]
  skip_filter :login_required, :only=>[:show, :index, :search]
    
  def index
    render :action => :search
  end
  
  def search
    render
  end

  def show
  end

  def new
  end

  def create
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
    @profile = Profile[params[:profile_id]]
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
