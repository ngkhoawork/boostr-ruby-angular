require 'rails_helper'

RSpec.describe SpendAgreementPublisher, type: :model do
  it { should belong_to :publisher }
  it { should belong_to :spend_agreement }

  it 'validate_uniqueness_of publisher_id' do
    spend_agreement_publisher
    is_expected.to validate_uniqueness_of(:publisher_id).scoped_to(:spend_agreement_id)
  end

  def spend_agreement_publisher
    @_spend_agreement_publisher ||= create :spend_agreement_publisher, spend_agreement: spend_agreement, publisher: publisher
  end

  def spend_agreement
    @_spend_agreement ||= create :spend_agreement, company: company
  end

  def company
    @_company ||= create :company
  end

  def publisher
    @_publisher ||= create :publisher, company: company
  end
end
