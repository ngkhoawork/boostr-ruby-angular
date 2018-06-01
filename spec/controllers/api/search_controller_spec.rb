require 'rails_helper'

RSpec.describe Api::SearchController, type: :controller do
  before do
    sign_in user
  end

  describe 'GET #all' do
    context 'when typeahead param is set' do
      it 'returns non activity records first' do
        create_list :deal, 10, name: 'testable', company: company
        create_list :activity, 1, company: company, activity_type: activity_type, client: advertiser
        get :all, query: 'test', typeahead: true, limit: 10, format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json.find{|record| record['searchable_type'] == 'Activity'}).to be_nil
      end

      it 'returns activity records if there is no other types' do
        create_list :deal, 4, name: 'test', company: company
        create_list :activity, 6, company: company, activity_type: activity_type, client: advertiser
        get :all, query: 'test', typeahead: true, limit: 10, format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json.select{|record| record['searchable_type'] == 'Activity'}.count).to eq(5)
      end
    end

    context 'when typeahead param is not set' do
      before do
        create :deal, name: 'test', company: company
        create :deal, name: 'new deal', company: company, advertiser: advertiser
        create :deal, name: 'new deal2', company: company, agency: agency
        create :contact, name: 'test contact', company: company, client: client
        create :contact, name: 'new contact', company: company, client: client, address: address
        create :contact, name: 'new contact2', company: company, client: advertiser
        create :io, name: 'test', company: company
        create :io, name: 'new io', company: company, advertiser: advertiser
        create :io, name: 'new io2', company: company, agency: agency
        create :activity, company: company, activity_type: activity_type, client: advertiser
      end

      it 'returns a list of search results' do
        get :all, query: 'test', format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json.length).to eq(12)
      end
    end
  end

  describe 'GET #count' do
    before do
      create_list :deal, 4, name: 'test', company: company
    end

    it 'returns search count' do
      get :count, query: 'test', format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['count']).to eq(4)
    end
  end

  private

  def activity_type
    @_activity_type ||= create :activity_type
  end

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
