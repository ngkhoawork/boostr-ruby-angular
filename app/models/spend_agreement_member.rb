class SpendAgreementMember < ActiveRecord::Base
  belongs_to :user
  belongs_to :spend_agreement
end
