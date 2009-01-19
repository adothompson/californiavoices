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

            # if profile becomes active send the activation email
            if @profile.is_active
              AccountMailer.deliver_activation @profile.user
            end
            
            page << "message('User has been marked as #{@profile.is_active ? 'active' : 'inactive'}');"
            page.replace_html @profile.dom_id('link'), (@profile.is_active ? 'deactivate' : 'activate')
            
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
    @results = Profile.find(:all).paginate(:page => @page, :per_page => @per_page)
  end
end
