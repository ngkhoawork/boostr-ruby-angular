class PublisherMember < ActiveRecord::Base
  belongs_to :publisher
  belongs_to :user

  validates :user_id, :publisher_id, presence: true

  delegate :name, to: :user, allow_nil: true
end
