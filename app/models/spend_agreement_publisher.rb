class SpendAgreementPublisher < ActiveRecord::Base
  belongs_to :spend_agreement
  belongs_to :publisher

  validates_uniqueness_of :publisher_id, scope: [:spend_agreement_id]

  scope :by_child_ids, -> (ids) { where(publisher_id: ids) }
end
