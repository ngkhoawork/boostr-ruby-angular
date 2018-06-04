class AssignmentRule < ActiveRecord::Base
  COUNTRY = 'country'.freeze
  SOURCE_URL = 'source_url'.freeze
  PRODUCT_NAME = 'product_name'.freeze
  TYPES = [COUNTRY, SOURCE_URL, PRODUCT_NAME]

  has_many :assignment_rules_users, dependent: :destroy
  has_many :users, through: :assignment_rules_users

  belongs_to :company

  validates :name, :company_id, presence: true

  before_create :set_position

  scope :by_company_id, -> (company_id) { where(company_id: company_id) }
  scope :order_by_position, -> { order(:position) }
  scope :not_default, -> { where(default: false) }
  scope :by_criteria_1, -> (criteria) { where("array_to_string(criteria_1, '||') ILIKE ?", "%#{criteria.downcase}%") }
  scope :by_criteria_2, -> (criteria) { where("array_to_string(criteria_2, '||') ILIKE ?", "%#{criteria.downcase}%") }
  scope :by_type, -> (type) { where(field_type: type) }

  def next_available_rule
    assignment_rules_users.next_available
  end

  private

  def set_position
    self.position =
      AssignmentRule
        .by_company_id(self.company.id)
        .order_by_position
        .last
        .position
        .next rescue 1
  end
end
