module TopicsHelper

  def topics_li topics
    html = ''
    topics.each do |t|
      # html+="<li>#{link_to h(t.name), stories_path(:search => {:q => t.name })}</li>"
      html+="<li>#{link_to h(t.name), topic_stories_path(t)}</li>"
    end
    html
  end

end
