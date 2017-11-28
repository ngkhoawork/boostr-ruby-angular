class PmpMember < ActiveRecord::Base
  belongs_to :pmp, required: true
  belongs_to :user, required: true

  validates :share, :from_date, :to_date, presence: true
end