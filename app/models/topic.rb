class Topic < ActiveRecord::Base

#  has_many :stories
  
  # to_param url
  def to_param
    "#{self.id}-#{name.to_safe_uri}"
  end
  
  # icon
  file_column :icon, :magick => {
    :versions => { 
      :big => {:crop => "1:1", :size => "150x150", :name => "big"},
      :medium => {:crop => "1:1", :size => "100x100", :name => "medium"},
      :small => {:crop => "1:1", :size => "50x50", :name => "small"}
    }
  }

end
