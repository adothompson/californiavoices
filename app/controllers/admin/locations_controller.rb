class Admin::LocationsController < ApplicationController

  def index
    @results = Location.find(:all, :order => "region_id ASC, created_at DESC").paginate(:page => @page, :per_page => @per_page)
  end

  def new
    @location = Location.new
  end

  def create
    @location = Location.new(params[:location])
    respond_to do |wants|
      if @location.save
        flash[:notice] = "Location was successfully created."
        wants.html { redirect_to(admin_locations_path) }
        wants.xml { head :created, :location => admin_locations_path }
      else
        flash[:error] = "Location could NOT be created."
        wants.html { render :action => 'new' }
        wants.xml { render :xml => @location.errors.to_xml }
      end
    end
    
  end
  
  def edit
    @location = Location.find params[:id]
  end

  def update
    @location = Location.find params[:id]
    if @location.update_attributes(params[:location])
      flash[:notice] = "Location successfully updated."
      redirect_to admin_locations_path
    else
      flash[:error] = "Location could NOT be updated."
      render :action => 'edit'
    end
  end
  
  private

  def allow_to
    super :admin, :all => true
  end
  
end
