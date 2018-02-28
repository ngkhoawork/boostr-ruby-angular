require 'rails_helper'

RSpec.describe Api::RequestsController, type: :controller do
  let(:user) { create :user }

  before do
    sign_in user
  end

  describe 'GET #index' do
    let!(:requests) { create_list :request, 5 }

    it 'returns list of all requests' do
      get :index

      expect(response).to be_success
      expect(json_response.length).to be 5
    end
  end

  describe "POST #create" do
    it 'creates a new request' do
      expect{
        post :create, request: request_params, format: :json
        expect(response).to be_success
      }.to change(Request, :count).by 1
    end

    it 'assigns current user as requester' do
      post :create, request: request_params, format: :json

      expect(json_response['requester_id']).to eq user.id
    end

    it 'assigns requestable item' do
      post :create, request: request_params, format: :json

      expect(json_response['requestable_type']).to eq 'ContentFee'
      expect(json_response['requestable_id']).to eq io.content_fees.first.id
    end

    it 'saves company id on request' do
      post :create, request: request_params, format: :json

      expect(Request.last.company_id).to be user.company_id
    end
  end

  describe 'PUT #update' do
    it 'updates request successfully' do
      put :update, id: request.id, request: { description: 'Money request inbound' }, format: :json

      expect(response).to be_success

      expect(request.reload.description).to eq 'Money request inbound'
    end
  end

  def request_params
    attributes_for :request,
      deal_id: won_deal.id,
      requestable_id: io.content_fees.first.id,
      requestable_type: 'ContentFee'
  end

  def won_deal
    @_won_deal ||= create :deal, stage: closed_won_stage
    @_deal_product ||= create :deal_product, deal: @_won_deal
    Deal::IoGenerateService.new(@_won_deal).perform unless @_won_deal.io.present?
    @_won_deal
  end

  def io
    Io.find_by_io_number won_deal.id
  end

  def closed_won_stage
    @_closed_won_stage ||= create :closed_won_stage
  end

  def request
    @_request ||= create :request
  end
end
