class AssignmentRule < ActiveRecord::Base
  has_many :assignment_rules_users
  has_many :users, through: :assignment_rules_users

  belongs_to :company

  validates :name, :company_id, presence: true

  before_create :set_position

  scope :by_company_id, -> (company_id) { where(company_id: company_id) }
  scope :order_by_position, -> { order(:position) }
  scope :default, -> { find_by(default: true) }
  scope :not_default, -> { where(default: false) }
  scope :by_countries, -> (country) { where("array_to_string(countries, '||') ILIKE ?", "%#{country.downcase}%") }
  scope :by_states, -> (state) { where("array_to_string(states, '||') ILIKE ?", "%#{state.downcase}%") }

  def next_available_rule
    assignment_rules_users.next_available
  end

  private

  def set_position
    self.position ||=
      AssignmentRule
        .by_company_id(self.company.id)
        .not_default
        .order_by_position
        .last
        .position
        .next
  end
end
