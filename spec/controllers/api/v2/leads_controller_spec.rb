require 'rails_helper'

describe Api::V2::LeadsController do
  describe 'POST #create' do
    it 'creates lead successfully' do
      expect {
        post :create, lead: valid_lead_params
      }.to change(Lead, :count).by(1)
    end
  end

  private

  def company
    @_company ||= create(:company, id: 11)
  end

  def user
    @_user ||= create :user, company: company
  end

  def valid_lead_params
    attributes_for :lead
  end
end
