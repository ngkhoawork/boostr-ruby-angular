require 'rails_helper'

RSpec.describe Option, type: :model do
  let(:company) { create :company }
  let(:field) { create :field, company: company }
  let(:option) { create :option, company: company, field: field }
  let(:deal) { create :deal, company: company }
  let(:value) { create :value, company: company, field: field, subject: deal, option: option }

  context 'validating' do
    it "ignores itself" do
      expect(build(:option, company: company, field: field)).to be_valid
    end

    it "validates the name uniqueness and is case insensitive" do
      option
      another_option = build(:option, company: company, field: field, name: option.name.downcase)
      expect(another_option).to be_invalid
      expect(another_option.errors[:name]).to be_present
    end

    it 'ignores duplicates from other fields' do
      option
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
