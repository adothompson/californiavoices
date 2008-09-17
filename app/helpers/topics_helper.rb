module TopicsHelper

  def topics_li topics
    html = ''
    topics.each do |t|
      html+="<li>#{link_to t.name, topic_path(t)}</li>"
    end
    html
  end

end
