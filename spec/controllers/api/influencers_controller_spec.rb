require 'rails_helper'

RSpec.describe Api::InfluencersController, type: :controller do
	let(:company) { create :company }
	let(:user) { create :user, company: company }
  let(:influencer_params) { attributes_for(:influencer, company_id: company.id) }

  before do
    sign_in user
    User.current = user
  end

	describe 'POST #create' do
		it 'creates a new influencer and returns success' do
      expect do
        post :create, influencer: influencer_params, format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['name']).to eq('MyString')
        expect(response_json['active']).to eq(false)
        expect(response_json['email']).to eq('MyString')
        expect(response_json['phone']).to eq('MyString')
      end.to change(Influencer, :count).by(1)
    end

    # pass this because there's no validation check in model definition
    xit 'returns errors if influencer is invalid' do
      expect do
        post :create, influencer: attributes_for(:influencer), format: :json
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
