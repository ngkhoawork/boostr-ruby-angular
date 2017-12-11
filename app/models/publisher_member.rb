class PublisherMember < ActiveRecord::Base
  belongs_to :publisher
  belongs_to :user

  validates :user_id, :publisher_id, presence: true
  validates :user_id, uniqueness: { scope: :publisher_id, message: 'already present as member' }

  delegate :name, to: :user, allow_nil: true

  def owner?
    owner
  end
end
