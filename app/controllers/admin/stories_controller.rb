class Admin::StoriesController < ApplicationController

  def index
    @results = Story.find(:all, :order => 'active ASC, created_at DESC').paginate(:page => @page, :per_page => @per_page)
  end

  def edit
    @story = Story.find params[:id]
  end

  def update
    @story = Story.find params[:id]
    if @story.update_attributes(params[:story])
      flash[:notice] = "Story successfully updated."
      redirect_to admin_stories_path
    else
      flash[:error] = "Story could NOT be updated."
      render :action => 'edit'
    end
  end

  # update active flag with js and put
  def activate
    @story = Story.find params[:id]
    respond_to do |wants|
      wants.js do
        render :update do |page|
          @story.toggle! :active
          page << "message('Story has been marked as #{@story.active ? 'active' : 'inactive'}');"
          page.replace_html @story.dom_id('link'), (@story.active? ? 'deactivate' : 'activate')
        end
      end
    end
  end
  
  private

  def allow_to
    super :admin, :all => true
  end
  
end
