xml = xml_instance unless xml_instance.nil?
xml.item do
  p = feed_item.item
  xml.title "#{p.profile.f} uploaded a story"
  xml.description p.description.blank? ? 'No description provided' : sanitize(textilize(p.description))
  xml.author "#{p.profile.email} (#{p.profile.f})"
  xml.pubDate p.updated_at
  xml.link story_url(p)
  xml.guid story_url(p)
end