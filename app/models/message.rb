# == Schema Information
# Schema version: 2
#
# Table name: messages
#
#  id          :integer(11)   not null, primary key
#  subject     :string(255)   
#  body        :text          
#  created_at  :datetime      
#  updated_at  :datetime      
#  sender_id   :integer(11)   
#  receiver_id :integer(11)   
#  read        :boolean(1)    not null
#

class Message < ActiveRecord::Base
  belongs_to :sender, :class_name => "Profile"
  belongs_to :receiver, :class_name => "Profile"
  validates_presence_of :body, :subject, :sender, :receiver
  attr_immutable :id, :sender_id, :receiver_id
  
  
  def unread?
    !read
  end
end
