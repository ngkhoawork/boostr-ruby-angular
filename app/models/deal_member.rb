class DealMember < ActiveRecord::Base
  belongs_to :deal
  belongs_to :user

  def name
    user.full_name if user.present?
  end
end
