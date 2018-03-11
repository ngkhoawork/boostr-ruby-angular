require 'rails_helper'

RSpec.describe Validation, type: :model do
  let!(:company) { create :company }
  let(:validation) { create :validation, company: company }
  let(:new_company) { create :company }

  context 'associations' do
    it { should belong_to(:company) }
    it { should have_one(:criterion) }
  end

  context 'validations' do
    it 'validates uniqueness of validation for company' do
      duplicate = build :validation, factor: validation.factor
      expect(duplicate).not_to be_valid
    end

    it 'allows to create same validations for different companies' do
      not_duplicate = build :validation, factor: validation.factor, company: new_company
      expect(not_duplicate).to be_valid
    end

    it 'allows to create different validations for same company_id' do
      not_duplicate = build :validation, company: company
      expect(not_duplicate).to be_valid
    end
  end
end
