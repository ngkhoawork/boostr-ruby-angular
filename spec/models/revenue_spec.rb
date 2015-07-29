require 'rails_helper'

RSpec.describe Revenue, type: :model do

  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:client) { create :client, company: company }

  describe 'uploading a good csv' do
    it 'creates a new revenue object for each row' do
      expect {
        Revenue.import(good_csv_file(client, user), company.id)
      }.to change(Revenue, :count).by(1)
    end

    it 'does not create any new revenue objects when they have already been created' do
      Revenue.import(good_csv_file(client, user), company.id)

      expect {
        Revenue.import(good_csv_file(client, user), company.id)
      }.to_not change(Revenue, :count)
    end

    it 'returns no errors when the upload is successful' do
      expect(Revenue.import(good_csv_file(client, user), company.id)).to eq([])
    end
  end

  describe 'uploading a bad csv' do
    it 'returns errors when a row is missing required data' do
      expect {
        response = Revenue.import(missing_required_csv(client, user), company.id)
        expect(response[0][:row]).to eq(1)
        expect(response[0][:message].length).to eq(3)
        expect(response[0][:message]).to include("Order number can't be blank")
        expect(response[0][:message]).to include("Line number can't be blank")
        expect(response[0][:message]).to include("Ad server can't be blank")
      }.to_not change(Revenue, :count)
    end

    it 'returns an error when the user is not found in the system' do
      expect {
        response = Revenue.import(missing_user_csv(client), company.id)
        expect(response[0][:row]).to eq(1)
        expect(response[0][:message].length).to eq(1)
        expect(response[0][:message]).to include("Sales Rep could not be found")
      }.to_not change(Revenue, :count)
    end

    it 'returns an error when the user is not found in the system' do
      expect {
        response = Revenue.import(missing_client_csv(user), company.id)
        expect(response[0][:row]).to eq(1)
        expect(response[0][:message].length).to eq(1)
        expect(response[0][:message]).to include("Client could not be found")
      }.to_not change(Revenue, :count)
    end
  end
end