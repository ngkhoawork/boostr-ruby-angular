class AssignmentRule < ActiveRecord::Base
  has_and_belongs_to_many :users

  belongs_to :company

  validates :name, :company_id, presence: true

  before_create :set_position

  scope :by_company_id, -> (company_id) { where(company_id: company_id) }
  scope :order_by_position, -> { order(:position) }

  private

  def set_position
    self.position ||= AssignmentRule.by_company_id(self.company.id).count
  end
end
