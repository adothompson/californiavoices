class Admin::ClippingsController < ApplicationController
  
  def index
    @story = Story.find params[:story_id], :include => :clippings
    respond_to do |wants|
      wants.html
      wants.xml {render :xml => @story.clippings.to_xml}
    end
  end

  def update
    @story = Story.find params[:story_id]
    clip = Clipping.find params[:id]

    # make sure all clipping preferred set to false
    @story.clippings.each do |c|
      c.preferred = false
      c.save!
    end

    clip.preferred = true
    
    respond_to do |wants|
      if clip.save
        flash[:notice] = "Default clipping was saved."
        wants.html { redirect_to(admin_story_clippings_path(@story)) }
        wants.xml { head :created, :location => admin_story_clippings_path(@story) }
      else
        flash[:error] = "Could not save default clipping."      
        format.html { render :action => 'index' }
        format.xml { render :xml => clip.errors.to_xml }
      end
    end
  rescue ActiveRecord::RecordInvalid
    flash[:error] = "Could not save default clipping."      
    render :action => 'index'
  end

  def create
    @story = Story.find params[:story_id], :include => :clippings
    @clip = Clipping.new(params[:clipping])
    respond_to do |wants|
      if @story.valid? && @story.clippings << @clip
        flash[:notice] = 'Clipping was successfully created.'
        wants.html { redirect_to(admin_story_clippings_path(@story)) }
        wants.xml { head :created, :location => admin_story_clippings_path(@story) }
      else
        flash[:error] = 'Clipping could NOT be created.'
        format.html { render :action => 'index' }
        format.xml { render :xml => @clip.errors.to_xml }
      end
    end
  rescue ActiveRecord::RecordInvalid
    flash[:error] = 'Clipping could NOT be created.'
    render :action => 'index'
  end

  def destroy
    @story = Story.find params[:story_id]
    @clip = Clipping.find params[:id]
    @clip.destroy
    redirect_to admin_story_clippings_path(@story)
  end
  
  private

  def allow_to
    super :admin, :all => true
  end
  
end
