require 'rails_helper'

RSpec.describe Team, type: :model do
  context 'scopes' do
    describe '#roots' do
      let(:company) { create :company }
      let(:parent) { create :parent_team, company: company }
      let!(:child) { create :child_team, company: company, parent: parent }

      it 'returns all parentless teams' do
        expect(Team.all.length).to eq(2)
        expect(Team.roots.length).to eq(1)
      end
    end
  end
end
