require 'rails_helper'

RSpec.describe Revenue, type: :model do

  let!(:company) { create :company }

  describe 'uploading a csv' do
    let(:csv_file) { File.read("#{Rails.root}/spec/support/revenue_example.csv") }

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
  end
end