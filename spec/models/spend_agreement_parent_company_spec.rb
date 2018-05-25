require 'rails_helper'

RSpec.describe SpendAgreementParentCompany, type: :model do
  it { should belong_to :spend_agreement }
  it { should belong_to :parent_company }

  it 'validate_uniqueness_of client_id' do
    spend_agreement_parent_company
    is_expected.to validate_uniqueness_of(:client_id).scoped_to(:spend_agreement_id)
  end

  def spend_agreement_parent_company
    @_spend_agreement_parent_company ||= create :spend_agreement_parent_company, spend_agreement: spend_agreement, parent_company: parent_company
  end

  def spend_agreement
    @_spend_agreement ||= create :spend_agreement, company: company
  end

  def company
    @_company ||= create :company
  end

  def parent_company
    @_parent_company ||= create :parent_client, company: company
  end
end
