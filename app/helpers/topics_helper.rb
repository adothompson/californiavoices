module TopicsHelper

  def topics_li topics
    html = ''
    topics.each do |t|
      html+="<li>#{link_to t.name, stories_path(:search => {:q => t.name })}</li>"
    end
    html
  end

end
