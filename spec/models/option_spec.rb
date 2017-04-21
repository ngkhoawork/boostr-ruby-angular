require 'rails_helper'

RSpec.describe Option, type: :model do
  let(:company) { create :company }
  let(:field) { create :field, company: company }
  let(:option) { create :option, company: company, field: field }
  let(:suboption) { create :option, company: company, option: option }
  let(:deal) { create :deal, company: company }
  let(:value) { create :value, company: company, field: field, subject: deal, option: option }


  context 'scopes' do
    describe 'by name' do
      it 'finds option by name' do
        create :option, name: 'Testy test', field: field

        expect(Option.by_name('Testy test').length).to be 1
      end

      it 'is case insensitive' do
        create :option, name: 'Testy test', field: field

        expect(Option.by_name('testy Test').length).to be 1
      end
    end

    it 'finds option by company id' do
      opt = create :option, name: 'Testy test', field: field

      expect(Option.for_company(opt.company_id)).to include opt
    end
  end

  context 'validating' do
    context 'option' do
      it "ignores itself" do
        expect(build(:option, company: company, field: field)).to be_valid
      end

      it "validates the name uniqueness and is case insensitive" do
        another_option = build(:option, company: company, field: field, name: option.name.downcase)
        expect(another_option).to be_invalid
        expect(another_option.errors[:name]).to be_present
      end

      it 'ignores duplicates from other fields' do
        another_field = create(:field, company: company)
        another_option = build(:option, company: company, field: another_field, name: option.name)
        expect(another_option).to be_valid
      end

      it 'ignores deleted time periods' do
        option.destroy
        another_option = build(:option, company: company, field: field, name: option.name)
        expect(another_option).to be_valid
      end
    end

    context 'suboption' do
      it 'ignores itself' do
        expect(build(:option, company: company, option: option)).to be_valid
      end

      it 'validates name uniqueness and is case insensitive' do
        another_suboption = build(:option, company: company, option: option, name: suboption.name.downcase)
        expect(another_suboption).to be_invalid
        expect(another_suboption.errors[:name]).to be_present
      end

      it 'ignores duplicates from other options' do
        another_field = create(:field, company: company)
        another_option = create(:option, field: another_field, company: company)
        another_suboption = build(:option, company: company, option: another_option, name: suboption.name)
        expect(another_suboption).to be_valid
      end

      it 'ignores deleted options' do
        suboption.destroy
        another_suboption = build(:option, company: company, option: option, name: suboption.name)
        expect(another_suboption).to be_valid
      end
    end
  end

  context 'set position' do
    it "sets the position" do
      expect(option.position).to be
    end
  end

  context 'used' do
    it "knows if it has been used in a value" do
      expect(option.used).to eq(false)
      value
      expect(option.used).to eq(true)
    end
  end
end
