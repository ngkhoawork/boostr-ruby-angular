require 'rails_helper'

RSpec.describe Api::RevenueController, type: :controller do

  let(:company) { create :company }
  let(:user) { create :user, company: company, email: 'msmith@buzzfeed.com' }
  let!(:another_user) { create :user, company: company, email: 'tjones@buzzfeed.com' }

  before do
    sign_in user
  end

  describe "POST #create" do
    let(:csv_file) { ActionDispatch::Http::UploadedFile.new(tempfile: File.new("#{Rails.root}/spec/support/revenue_example.csv")) }

    it 'calls import on Revenue and returns success' do
      post :create, file: csv_file, format: :json
      expect(response).to be_success
    end
  end
end
