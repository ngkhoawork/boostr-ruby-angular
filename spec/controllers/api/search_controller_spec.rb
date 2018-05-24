require 'rails_helper'

RSpec.describe Api::SearchController, type: :controller do
  before do
    sign_in user
  end

  describe "GET #all" do
    it 'returns a list of search results' do
      create :deal, name: 'test', company: company
      create :deal, name: 'new deal', company: company, advertiser: advertiser
      create :deal, name: 'new deal2', company: company, agency: agency
      create :contact, name: 'test contact', company: company, client: client
      create :contact, name: 'new contact', company: company, client: client, address: address
      create :contact, name: 'new contact2', company: company, client: advertiser
      create :io, name: 'test', company: company
      create :io, name: 'new io', company: company, advertiser: advertiser
      create :io, name: 'new io2', company: company, agency: agency

      get :all, query: 'test', format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(11)
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def address
    @_address ||= create :address, email: 'test@boostrcrm.com'
  end

  def client
    @_client ||= create :client, company: company, name: 'new client'
  end

  def advertiser
    @_advertiser ||= create :client, :advertiser, company: company, name: 'test advertiser'
  end

  def agency
    @_agency ||= create :client, :agency, company: company, name: 'test agency'
  end

  def user
    @_user ||= create :user, company: company
  end
end
