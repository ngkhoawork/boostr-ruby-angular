class Request < ActiveRecord::Base
  belongs_to :requester, class_name: 'User'
  belongs_to :assignee, class_name: 'User'
  belongs_to :deal
  belongs_to :requestable, polymorphic: true

  validates_length_of :description, maximum: 1000
  validates_length_of :resolution, maximum: 1000
end
