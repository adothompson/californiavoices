module RegionsHelper

  def regions_li regions
    html = ''
    regions.each do |r|
      html+="<li>#{link_to r.name, stories_path(:search => {:q => r.name})}</li>"
    end
    html
  end

end
