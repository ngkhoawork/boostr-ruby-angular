require 'rails_helper'

describe GoogleSheetsApiClient, vcr: true do
  describe '::add_row' do
    let(:deal) { create :deal, id: 1000 }

    xit 'should add new row to spreadsheet' do
      expect(described_class.add_row('1ADkamKx7LJB1SzXmCMy29Yw3ocA0VBeJ5mrV3ugz0Wg', deal)).to be true
    end
  end

  describe '::update_row' do
    let(:deal) { create :deal, id: 2000 }

    before do
      described_class.add_row('1ADkamKx7LJB1SzXmCMy29Yw3ocA0VBeJ5mrV3ugz0Wg', deal)
    end

    xit 'should update existing row in spreadsheet' do
      expect(described_class.update_row('1ADkamKx7LJB1SzXmCMy29Yw3ocA0VBeJ5mrV3ugz0Wg', deal)).to be true
    end
  end
end
