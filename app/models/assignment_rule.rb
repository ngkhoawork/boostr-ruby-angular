class AssignmentRule < ActiveRecord::Base
  has_many :assignment_rules_users
  has_many :users, through: :assignment_rules_users

  belongs_to :company

  validates :name, :company_id, presence: true

  before_create :set_position

  scope :by_company_id, -> (company_id) { where(company_id: company_id) }
  scope :order_by_position, -> { order(:position) }
  scope :by_countries, -> (country) { find_by("array_to_string(countries, '||') ILIKE ?", "%#{country.downcase}%") }
  scope :by_states_and_countries, -> (state, country) do
    find_by("array_to_string(states, '||') ILIKE ? AND array_to_string(countries, '||') ILIKE ?",
            "%#{state.downcase}%", "%#{country.downcase}%")
  end

  def next_available_rule
    assignment_rules_users.next_available
  end

  private

  def set_position
    self.position ||= AssignmentRule.by_company_id(self.company.id).count
  end
end
