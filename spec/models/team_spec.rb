require 'rails_helper'

RSpec.describe Team, type: :model do
  let(:company) { create :company }
  let(:parent) { create :parent_team, company: company }
  let!(:child) { create :child_team, company: company, parent: parent }
  let(:user) { create :user, team: parent }

  context 'scopes' do
    describe '#roots' do

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

  context '#all_deals_for_time_period' do
    let(:time_period) { create :time_period, company: company }
    let(:parent_member) { create :user, company: company, team: parent }
    let(:child_member) { create :user, company: company, team: child }
    let(:parent_deal) { create :deal, company: company, start_date: time_period.start_date, end_date: time_period.end_date }
    let(:child_deal) { create :deal, company: company, start_date: time_period.start_date, end_date: time_period.end_date }
    let!(:parent_deal_member) { create :deal_member, deal: parent_deal, user: parent_member }
    let!(:child_deal_member) { create :deal_member, deal: child_deal, user: child_member }

    it 'returns all of the team deals as well as all of the team\'s children\'s deals' do
      all_deals = parent.all_deals_for_time_period(time_period)
      expect(all_deals.flatten.uniq.length).to eq(2)
    end
  end
end
