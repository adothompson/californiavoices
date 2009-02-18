module RegionsHelper

  def regions_li regions
    html = ''
    regions.each do |r|
#       html+="<li>#{link_to h(r.name), stories_path(:search => {:q => r.name})}</li>"
      html+="<li>#{link_to h(r.name), region_stories_path(r)}</li>"
    end
    html
  end

end
