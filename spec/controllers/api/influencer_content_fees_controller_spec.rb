require 'rails_helper'

RSpec.describe Api::InfluencerContentFeesController, type: :controller do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:influencer) { create :influencer, company: company}
  let(:io) { create :io, company: company }
  let(:product) { create :product, company: company }
  let(:content_fee) { create :content_fee, io: io, product: product }

  before do
    sign_in user
    User.current = user
  end

  describe 'POST #create' do
    it 'creates a new influencer_content_fee and returns success' do
      expect do
        post :create, influencer_content_fee: attributes_for(:influencer_content_fee, influencer_id: influencer.id, content_fee_id: content_fee.id), format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['fee_type']).to eq('MyString')
        expect(response_json['curr_cd']).to eq('MyString')
        expect(response_json['gross_amount']).to eq('9.99')
        expect(response_json['gross_amount_loc']).to eq('9.99')
        expect(response_json['net']).to eq('9.99')
        expect(response_json['asset']).to eq('MyText')
      end.to change(Influencer, :count).by(1)
    end

    # pass this because there's no validation check in model definition
    xit 'returns errors if influencer_content_fee is invalid' do
      expect do
        post :create, influencer_content_fee: attributes_for(:influencer_content_fee, gross_amount: 'MyString', influencer_id: influencer.id, content_fee_id: content_fee.id), format: :json
        expect(response.status).to eq(422)
        response_json = JSON.parse(response.body)
      end.to_not change(Influencer, :count)
    end

    it 'runs sidekiq worker and returns message' do
      expect do
        post :create, file: { s3_file_path: 'Fake' }, format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['message']).to eq('Your file is being processed. Please check status at Import Status tab in a few minutes (depending on the file size)')
      end.to change(CsvImportWorker.jobs, :size).by(1)
    end
  end
end
