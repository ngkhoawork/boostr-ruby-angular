class SpendAgreementCustomField < ActiveRecord::Base
  belongs_to :company
  belongs_to :spend_agreement
end
