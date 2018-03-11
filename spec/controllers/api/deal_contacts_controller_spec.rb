require 'rails_helper'

RSpec.describe Api::DealContactsController, type: :controller do
  let!(:company) { create :company }
  let!(:billing_validation) { create :validation, factor: 'Billing Contact Full Address', value_type: 'Boolean' }
  let!(:user) { create :user }
  let!(:agency) { create :client }
  let!(:advertiser) { create :client }
  let!(:agency_contact) { create :contact, clients: [agency] }
  let!(:advertiser_contacts) { create_list :contact, 9, clients: [advertiser] }
  let!(:deal) { create :deal, advertiser: advertiser, agency: agency }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'returns a list of possible contacts' do
      get :index, deal_id: deal.id, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(10)
    end

    it 'accepts name attribute' do
      get :index, deal_id: deal.id, name: agency_contact.name, format: :json
      response_json = JSON.parse(response.body)

      expect(response).to be_success
      expect(response_json.length).to eq(1)
      expect(response_json[0]['id']).to eq(JSON.parse(agency_contact.to_json)['id'])
      expect(response_json[0]['name']).to eq(JSON.parse(agency_contact.to_json)['name'])
    end
  end

  describe 'POST #create' do
    let(:new_contact) { create :contact }

    it 'creates new deal contact' do
      expect do
        post :create, deal_id: deal.id, deal_contact: { contact_id: new_contact.id } , format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['contact_id']).to eq(new_contact.id)
      end.to change(DealContact, :count).by(1)
    end
  end

  describe 'DELETE #destroy' do
    let!(:deal) { create :deal_with_contacts, company: user.company }

    it 'removes contacts from a deal' do
      expect do
        delete :destroy, id: deal.deal_contacts.first.id, deal_id: deal.id, format: :json
        expect(response).to be_success
      end.to change(DealContact, :count).by(-1)
    end
  end
end
