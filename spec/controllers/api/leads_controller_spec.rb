require 'rails_helper'

describe Api::LeadsController do
  before { sign_in user }

  describe 'GET #accept' do
    it 'accept lead successfully' do
      expect(lead.status).to be_nil

      get :accept, id: lead.id

      expect(lead.reload.status).to eq Lead::ACCEPTED
      expect(lead.reload.accepted_at).not_to be_nil
    end
  end

  describe 'GET #reject' do
    it 'reject lead successfully' do
      expect(lead.status).to be_nil

      get :reject, id: lead.id

      expect(lead.reload.status).to eq Lead::REJECTED
      expect(lead.reload.rejected_at).not_to be_nil
    end
  end
  
  describe 'GET #reassign' do
    it 'reassign lead successfully' do
      get :reassign, id: lead.id, user_id: user.id

      expect(lead.reload.user_id).to eq user.id
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end

  def lead
    @_lead ||= create :lead, company: company
  end
end
