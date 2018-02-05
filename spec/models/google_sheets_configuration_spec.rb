require 'rails_helper'

describe GoogleSheetsConfiguration do
  describe 'associations' do
    it { should have_one(:google_sheets_details) }
  end
end
