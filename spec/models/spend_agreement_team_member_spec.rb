require 'rails_helper'

RSpec.describe SpendAgreementTeamMember, type: :model do
  it { should belong_to :user }
  it { should belong_to :spend_agreement }

  it 'validate_uniqueness_of user_id' do
    spend_agreement_team_member
    is_expected.to validate_uniqueness_of(:user_id).scoped_to(:spend_agreement_id)
  end

  def spend_agreement_team_member
    @_spend_agreement_team_member ||= create :spend_agreement_team_member, spend_agreement: spend_agreement, user: user
  end

  def spend_agreement
    @_spend_agreement ||= create :spend_agreement, company: company
  end

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end
end
