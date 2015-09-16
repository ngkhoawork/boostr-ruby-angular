class TimePeriod < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company
  has_many :quotas

  validates :name, :start_date, :end_date, presence: true

  validate :unique_name

  after_create do
    company.users.each do |user|
      quotas.create(user_id: user.id, company_id: company.id)
    end
  end

  protected

  # Because we have soft-deletes uniqueness validations must be custom
  def unique_name
    return true unless company

    scope = company.time_periods.where('name = ?', self.name)
    scope = scope.where('id <> ?', self.id) if self.id

    errors.add(:name, 'Name has already been taken') if scope.count > 0
  end
end
