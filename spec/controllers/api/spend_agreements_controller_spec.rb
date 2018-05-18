require 'rails_helper'

describe Api::SpendAgreementsController, type: :controller do
  before do
    sign_in user
    company.fields.find_or_create_by(subject_type: 'Multiple', name: 'Spend Agreement Type', value_type: 'Option', locked: true)
    company.fields.find_or_create_by(subject_type: 'Multiple', name: 'Spend Agreement Status', value_type: 'Option', locked: true)
  end

  describe "GET #index" do
    before do
      spend_agreement
    end

    it 'responds with ok status' do
      get :index, {}

      expect(response).to be_success
    end

    it 'matches the json schema' do
      get :index, {}

      expect(json_response[0]).to match_response_schema('spend_agreement')
    end

    it 'gets a list of all spend agreements' do
      get :index, {}

      expect(json_response.count).to eq(1)
    end

    context 'contains assigned advertisers' do
      it 'returns advertisers' do
        get :index, {}

        advertisers = json_response[0]['advertisers']

        expect(response).to be_success
        expect(advertisers.count).to eq(1)
      end
    end

    context 'contains agencies' do
      it 'returns agencies' do
        get :index, {}

        agencies = json_response[0]['agencies']

        expect(response).to have_http_status(:ok)
        expect(agencies.count).to eq(1)
      end
    end
  end

  describe "GET #show" do
    context 'with valid id' do
      it 'returns spend agreement record' do
        get :show, id: spend_agreement.id

        expect(json_response).not_to eq({})
        expect(json_response['id']).to eq(spend_agreement.id)
      end

      it 'returns not found in case of unexisting record' do
        get :show, id: spend_agreement.id + 1

        expect(json_response['message']).to eq('Record not found')
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST #create" do
    it 'creates new record' do
      expect{
        post :create, { spend_agreement: attributes_for(:spend_agreement) }
      }.to change{SpendAgreement.count}.by(+1)
    end

    it 'creates a spend_agreement_parent_company' do
      expect{
        post :create, spend_agreement_with_parent_company
      }.to change{SpendAgreementParentCompany.count}.by(1)

      expect(SpendAgreement.last.parent_companies.last.id).to eq(parent_company.id)
    end

    it 'creates a spend_agreement_publisher' do
      expect{
        post :create, spend_agreement_with_publisher
      }.to change{SpendAgreementPublisher.count}.by(+1)

      expect(SpendAgreement.last.publishers.last.id).to eq(publisher.id)
    end
  end

  private

  def user
    @_user ||= create :user, company: company
  end

  def company
    @_company ||= create :company
  end

  def agency
    @_agency ||= create(:client, :agency)
  end

  def advertiser
    @_advertiser ||= create(:client, :advertiser)
  end

  def parent_company
    @_parent_company ||= create :parent_client
  end

  def publisher
    @_publisher ||= create :publisher, company: company
  end

  def spend_agreement
    @spend_agreement ||= create :spend_agreement, client_ids: [advertiser.id, agency.id]
  end

  def spend_agreement_with_parent_company
    sa = attributes_for :spend_agreement, parent_companies_ids: [parent_company.id], company: company
    { spend_agreement: sa }
  end

  def spend_agreement_with_publisher
    sa = attributes_for :spend_agreement, publishers_ids: [publisher.id], company: company
    { spend_agreement: sa }
  end
end
