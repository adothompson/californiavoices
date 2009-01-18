module StoriesHelper

  def clipping story, thumb = :medium, img_opts = {}
    return "" if story.nil?
    clipping = story.clippings.first || nil
    img_opts = {:title => story.title, :alt => story.title, :class => thumb}.merge(img_opts)
    clipping.nil? ? link_to(image_tag('video_icon_small.jpg'), story_path(story)) : link_to(image_tag(clipping.public_filename(thumb)), story_path(story))    
  end
  
end
