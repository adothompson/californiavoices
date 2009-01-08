class Admin::UsersController < ApplicationController
  before_filter :search_results, :except => [:destroy]
  
  def index
    render
  end
  
  def update
    @profile = Profile.find(params[:id])
    respond_to do |wants|
      wants.js do
        render :update do |page|
          if @p == @profile
            page << "message('You cannot deactivate yourself!');"
          else
            @profile.toggle! :is_active
            page << "message('User has been marked as #{@profile.is_active ? 'active' : 'inactive'}');"
            page.replace_html @profile.dom_id('link'), (@profile.is_active ? 'deactivate' : 'activate')
            
            # if profile becomes active send the activation email
            if @profile.is_active
              AccountMailer.deliver_activation @profile.user
            end
          end
        end
      end
    end
  end

  def destroy
    @profile = Profile.find(params[:id])
    @user = @profile.user
   
    respond_to do |wants|
      @user.destroy      
      
      wants.js do        
        render :update do |page| 
          page.alert('User account, and all data, have been deleted.')
        end
      end
    end
  end

  private
  
  def allow_to
    super :admin, :all => true
  end
  
  def search_results
    #      if params[:search]
    #        p = params[:search].dup
    #      else
    #        p = []
    #      end
    #      @results = Profile.search((p.delete(:q) || ''), p).paginate(:page => @page, :per_page => @per_page)
    @results = Profile.find(:all).paginate(:page => @page, :per_page => @per_page)
  end
end
