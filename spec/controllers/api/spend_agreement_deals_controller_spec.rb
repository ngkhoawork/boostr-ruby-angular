require 'rails_helper'

describe Api::SpendAgreementDealsController, type: :controller do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "returns http success" do
      get :index, spend_agreement_id: sa.id
      expect(response).to be_success
    end
  end

  describe "POST #create" do
    it "creates a record" do
      expect{
        post :create, spend_agreement_id: sa.id, spend_agreement_deal: spend_agreement_deal_params
      }.to change(SpendAgreementDeal, :count).by(1)
    end
  end

  describe "DELETE #destroy" do
    it 'deletes the record' do
      spend_agreement_deal = create :spend_agreement_deal, deal: deal, spend_agreement: sa

      expect {
        delete :destroy, spend_agreement_id: sa.id, id: spend_agreement_deal.id
      }.to change(SpendAgreementDeal, :count).by -1
    end
  end

  describe 'GET #available_to_match' do
    it 'shows a list of matching but not yet assigned deals' do
      create_matching_deals

      get :available_to_match, spend_agreement_id: sa.id

      expect(json_response.length).to be 3
    end
  end

  def sa(opts={})
    defaults = {
      company: company,
      client_ids: [advertiser.id, agency.id],
      manually_tracked: true,
      start_date: Date.new(2017, 1, 1),
      end_date: Date.new(2017, 12, 31)
    }
    @_sa ||= create :spend_agreement, defaults.merge(opts)
  end

  def spend_agreement_deal_params
    {deal_id: deal.id}
  end

  def advertiser
    @advertiser ||= create :client, :advertiser
  end

  def agency
    @agency ||= create :client, :agency
  end

  def deal
    @_deal ||= create :deal
  end

  def create_matching_deals
    create_list :deal, 3, {
      agency: agency,
      advertiser: advertiser,
      start_date: Date.new(2017, 1, 1),
      end_date: Date.new(2017, 5, 5)
    }
  end
end
