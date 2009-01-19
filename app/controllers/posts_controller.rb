class PostsController < ApplicationController

  before_filter :login_required

  def create    
    begin
      # @page = Page.find params[:page_id]
      @story = Story.find params[:story_id]
      
      @post = Post.build params[:post].merge(:user => @u, :story => @story)
      @post.save!
      
      respond_to do |wants|
        wants.html {
          redirect_to story_url(@story)
        }
        wants.xml {
          render :xml => @post.to_xml, :status => 500
        }
      end
      return
    rescue ActiveRecord::RecordInvalid
      msg = @post.errors.full_messages.to_s
    end
    flash[:bad_reply] = msg
    respond_to do |wants|
      wants.html {
        redirect_to page_url(@page, :anchor => 'reply-form')
      }
      wants.xml {
        render :xml => msg, :status => 400
      }
    end
  end
 
  def edit
    render
  end
  
  def save
    if params[:save]
      @post.update_attribute('body', params[:body])
    elsif params[:destroy]
      @post.destroy
      return(render :action => 'destroy')
    end
  end

  private

  def allow_to
    super :owner, :all => true
    super :user, :only => [:create]
  end
  
end
