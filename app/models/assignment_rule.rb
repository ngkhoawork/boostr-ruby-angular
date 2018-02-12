class AssignmentRule < ActiveRecord::Base
  has_and_belongs_to_many :users

  belongs_to :company

  validates :name, :company_id, presence: true

  scope :by_company_id, -> (company_id) { where(company_id: company_id) }
end
