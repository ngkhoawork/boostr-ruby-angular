require 'rails_helper'

describe Api::LeadsController do
  before { sign_in user }

  describe 'GET #accept' do
    it 'accept lead successfully' do
      expect(lead.status).to be_nil

      get :accept, id: lead.id

      expect(lead.reload.status).to eq Lead::ACCEPTED
    end
  end

  describe 'GET #reject' do
    it 'reject lead successfully' do
      expect(lead.status).to be_nil

      get :reject, id: lead.id

      expect(lead.reload.status).to eq Lead::REJECTED
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
