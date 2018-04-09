require 'rails_helper'

RSpec.describe Stage, type: :model do
  let!(:company) { create :company }
  let(:user) { create :user, company: company }

  context 'scopes' do
    describe 'active' do
      let!(:active_stage) { create :stage, company: company }
      let!(:inactive_stage) { create :stage, company: company, active: false }

      it 'returns all active stages' do
        expect(Stage.all.length).to eq(2)
        expect(Stage.active.length).to eq(1)
        expect(Stage.active).to include(active_stage)
      end
    end
  end

  context 'colors' do
    it 'blends a color' do
      s = build(:stage, probability: 20)
      expect(s.send(:color_for_probability)).to eq("#ffe5d6")
    end
  end
end
