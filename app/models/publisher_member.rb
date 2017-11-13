class PublisherMember < ActiveRecord::Base
  belongs_to :publisher
  belongs_to :user

  validates :user_id, :publisher_id, presence: true
end
