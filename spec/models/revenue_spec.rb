require 'rails_helper'

RSpec.describe Revenue, type: :model do

  let!(:company) { create :company }

  describe 'uploading a csv' do
    let(:csv_file) { File.read("#{Rails.root}/spec/support/revenue_example.csv") }
    let(:bad_csv_file) { File.read("#{Rails.root}/spec/support/revenue_example_2.csv")  }

    it 'creates a new revenue object for each row' do
      expect {
        Revenue.import(csv_file, company.id)
      }.to change(Revenue, :count).by(13)
    end

    it 'does not create any new revenue objects when they have already been created' do
      Revenue.import(csv_file, company.id)

      expect {
        Revenue.import(csv_file, company.id)
      }.to_not change(Revenue, :count)
    end

    it 'returns no errors when the upload is successful' do
      expect(Revenue.import(csv_file, company.id)).to eq([])
    end

    it 'returns errors when a row is missing required data' do
      response = Revenue.import(bad_csv_file, company.id)
      expect(response[0][:row]).to eq(15)
      expect(response[0][:message].length).to eq(3)
      expect(response[0][:message]).to include("Order number can't be blank")
      expect(response[0][:message]).to include("Line number can't be blank")
      expect(response[0][:message]).to include("Ad server can't be blank")
    end
  end
end