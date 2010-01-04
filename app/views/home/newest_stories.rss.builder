
xml.instruct! :xml, :version=>"1.0"
xml.rss(:version=>"2.0") do
  xml.channel do
    xml.title "#{SITE_NAME} Newest Story Feed"
    xml.link SITE
    xml.description "This feed shows what stories have recently been added to #{SITE_NAME}"
    xml.language 'en-us'
    new_stories.each do |new_story|
      xml.item do
        xml.title "#{new_story.title}"
        xml.description "#{new_story.description} #{link_to('&gt;&gt; view', story_url(new_story))}"
        xml.author ""
        xml.pubDate new_story.created_at
        xml.link story_url(new_story)
        xml.guid story_url(new_story)
      end
    end
  end
end