require 'rails_helper'

RSpec.describe SpendAgreementClient, type: :model do
  it { is_expected.to belong_to :spend_agreement }
  it { is_expected.to belong_to :client }

  it 'validates_uniqueness_of client_id' do
    spend_agreement_client
    is_expected.to validate_uniqueness_of(:client_id).scoped_to(:spend_agreement_id)
  end

  def spend_agreement_client
    @spend_agreement_client ||= create :spend_agreement_client, client: client
  end

  def client
    @client ||= create :client, company: company
  end

  def company
    @company ||= create :company
  end
end
