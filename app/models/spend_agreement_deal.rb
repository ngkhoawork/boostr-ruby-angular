class SpendAgreementDeal < ActiveRecord::Base
  belongs_to :deal
  belongs_to :spend_agreement

  scope :exclude_ids, -> ids { where.not(id: ids) if ids.present? }
end
