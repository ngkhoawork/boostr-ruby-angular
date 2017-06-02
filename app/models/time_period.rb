class TimePeriod < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :company
  has_many :quotas
  has_many :snapshots

  validates :name, :start_date, :end_date, presence: true
  validate :unique_name

  after_create do
    company.users.each do |user|
      quotas.create(user_id: user.id, company_id: company.id)
    end
  end

  scope :current_year_quarters, -> (company_id) do
    where(company_id: company_id).where("date(end_date) - date(start_date) < 100")
                                 .where("extract(year from start_date) = ?", Date.current.year)
  end

  scope :current_quarter, -> do
    where(period_type: 'quarter').find_by('start_date <= ? AND end_date >= ?', Date.current, Date.current)
  end

  scope :all_quarter, -> { where(period_type: 'quarter') }

  def self.now
    where('start_date <= ? AND end_date >= ?', Time.now, Time.now).first
  end

  protected

  # Because we have soft-deletes uniqueness validations must be custom
  def unique_name
    return true unless company && name
    scope = company.time_periods.where('LOWER(name) = ?', self.name.downcase)
    scope = scope.where('id <> ?', self.id) if self.id

    errors.add(:name, 'Name has already been taken') if scope.count > 0
  end
end
