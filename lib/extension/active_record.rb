ActiveRecord::Base.class_eval do
  
  # used to automatically apply greencloth to a field and store it in another field.
  # for example:
  # 
  #    format_attribute :description
  #
  # Will save an html copy in description_html. This other column must exist
  #
  def self.format_attribute(attr_name)
    define_method(:body)       { read_attribute attr_name }
    define_method(:body_html)  { read_attribute "#{attr_name}_html" }
    define_method(:body_html=) { |value| write_attribute "#{attr_name}_html", value }
    before_save :format_body
    define_method(:format_body) {
      if !body.empty? # and (body_html.empty? or (send("#{attr_name}_changed?") and !send("#{attr_name}_html_changed?")))
        body.strip!
        self.body_html = RedCloth.new(body).to_html
      end
    }
  end

end
