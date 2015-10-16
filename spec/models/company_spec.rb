require 'rails_helper'

RSpec.describe Company, type: :model do
  let(:company) { create :company }

  context 'before create' do
    it 'creates default fields' do
      expect {
        create :company
      }.to change(Field, :count).by(3)
    end

    it 'creates default field options' do
      expect {
        create :company
      }.to change(Option, :count).by(2)
    end
  end
end