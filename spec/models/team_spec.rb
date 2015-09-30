require 'rails_helper'

RSpec.describe Team, type: :model do
  context 'scopes' do
    describe '#roots' do
      let(:company) { create :company }
      let(:parent) { create :parent_team, company: company }
      let!(:child) { create :child_team, company: company, parent: parent }
      let(:user) { create :user, team: parent }

      it 'returns all parentless teams' do
        expect(Team.all.length).to eq(2)
        expect(Team.roots(true).length).to eq(1)
        expect(Team.roots(false).length).to eq(2)
      end

      it 'has many members that only belong to the company' do
        user.update_attributes(company_id: company.id)
        expect(parent.reload.members).to include(user)
      end

      it 'has no members because they do not belong to the company' do
        expect(parent.reload.members).to_not include(user)
      end
    end
  end
end
