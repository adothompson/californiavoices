module RegionsHelper

  def regions_li regions
    html = ''
    regions.each do |r|
      html+="<li>#{link_to r.name, region_path(r)}</li>"
    end
    html
  end

end
