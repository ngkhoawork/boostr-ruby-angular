class SpendAgreementParentCompany < ActiveRecord::Base
  belongs_to :spend_agreement
  belongs_to :parent_company, class_name: "Client", foreign_key: 'client_id'

  validates_uniqueness_of :client_id, scope: [:spend_agreement_id]

  scope :by_child_ids, -> (ids) { where(client_id: ids) }
  scope :existing_items, -> { pluck(:client_id) }
end
