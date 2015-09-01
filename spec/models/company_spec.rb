require 'rails_helper'

RSpec.describe Company, type: :model do
  let(:company) { create :company }

  context 'CustomValues' do
    let!(:stage) { create :stage, company: company }

    describe 'values' do
      it 'returns a list of the values for Stage' do
        expect(company.values(Stage)).to include(stage)
      end
    end

    describe 'fields' do
      it 'returns a list of fields with their name and values' do
        deals = { name: 'Deals', fields_classes: [stage.class] }
        expect(company.fields(deals)[0][:name]).to eq('Stages')
      end
    end

    describe 'settings' do
      it 'returns a list of settings objects with their field names and values' do
        settings = company.settings
        expect(settings.length).to eq(5)
        expect(settings[0][:fields].length).to eq(1)
        expect(settings[0][:fields][0][:values].length).to eq(1)
      end
    end
  end
end