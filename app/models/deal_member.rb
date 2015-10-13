class DealMember < ActiveRecord::Base
  belongs_to :deal
  belongs_to :user

  validates :share, :user_id, :deal_id, presence: true

  def name
    user.name if user.present?
  end
end
