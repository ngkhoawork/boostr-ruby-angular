class TimePeriod < ActiveRecord::Base
  belongs_to :company
  has_many :quotas

  validates :name, :start_date, :end_date, presence: true

  after_create do
    company.users.each do |user|
      quotas.create(user_id: user.id, company_id: company.id)
    end
  end
end
