require 'rails_helper'

describe Api::SpendAgreementIosController, type: :controller do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  before :all do
    Io.skip_callback(:save, :after, :update_revenue_fact_callback)
  end

  after :all do
    Io.set_callback(:save, :after, :update_revenue_fact_callback)
  end

  before :each do
    sign_in user
  end

  describe "GET #index" do
    it "returns http success" do
      get :index, spend_agreement_id: sa.id

      expect(response).to be_success
    end

    it 'lists ios' do
      sa.spend_agreement_deals.create(deal_id: io.deal.id)

      get :index, spend_agreement_id: sa.id

      expect(json_response.first['id']).to eq io.id
    end
  end

  def sa(opts={})
    defaults = {
      company: company
    }
    @_sa ||= create :spend_agreement, defaults.merge(opts)
  end

  def io
    @_io ||= create :io, company: company
  end
end
