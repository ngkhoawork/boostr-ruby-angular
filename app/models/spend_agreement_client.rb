class SpendAgreementClient < ActiveRecord::Base
  belongs_to :client
  belongs_to :spend_agreement
  has_one :account_dimension, foreign_key: 'id', primary_key: :client_id

  validates_uniqueness_of :client_id, scope: [:spend_agreement_id]

  scope :by_child_ids, -> (ids) { where(client_id: ids) }
end
