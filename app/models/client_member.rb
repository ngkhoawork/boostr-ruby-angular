class ClientMember < ActiveRecord::Base
  belongs_to :client
  belongs_to :user

  validates :share, :role, :user_id, :client_id, presence: true

  def as_json(options = {})
    super(options.merge(include: [:client, :user]))
  end
end