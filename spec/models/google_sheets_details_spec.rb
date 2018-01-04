require 'rails_helper'

describe GoogleSheetsDetails do
  describe 'associations' do
    it { should belong_to(:api_configuration) }
  end

  describe 'validations' do
    it { should validate_presence_of(:sheet_id) }
  end
end
