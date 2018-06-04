class SpendAgreementContact < ActiveRecord::Base
  belongs_to :contact
  belongs_to :spend_agreement
end
