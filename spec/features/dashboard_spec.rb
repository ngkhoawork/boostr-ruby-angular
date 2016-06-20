require 'rails_helper'

feature 'Dashboard' do
  let(:company) { Company.first }
  let(:user) { create :user }
  let!(:parent) { create :parent_team, leader: user }
  let!(:time_period) { create :time_period }
  let!(:child) { create :child_team, parent: parent }
  let(:stage) { create :stage, probability: 100 }
  let(:deal) { create :deal, stage: stage, start_date: "2015-01-01", end_date: "2015-12-31"  }
  let(:member) { create :user, team: child }
  let!(:deal_member) { create :deal_member, deal: deal, user: member, share: 100 }
  let!(:deal_product) { create :deal_product, deal: deal, budget: 200000, start_date: "2015-01-01", end_date: "2015-01-31" }

  describe 'as a leader' do
    let!(:quota) { create :quota, user: user, value: 20000, time_period: time_period }

    before do
      login_as user, scope: :user
      allow_any_instance_of(Api::DashboardsController).to receive(:time_period).and_return(time_period)
      visit '/'
      expect(page).to have_css('#dashboard')
    end

    scenario 'shows the stats box and open deals', js: true do
      within '#stats' do
        expect(find('.attainment')).to have_text '10% ATTAINMENT'
        expect(find('.quota')).to have_text '$20000 QUOTA'
        expect(find('.forecast')).to have_text '$2000 FORECAST'
        expect(find('.gap-to-goal')).to have_text '$18000 GAP TO GOAL'
      end

      within '#deals' do
        expect(page).to have_css '.no-deals'
      end

      within '#alerts' do
        expect(page).to have_css '.no-alerts'
      end

      within '#activities.section' do
        expect(page).to have_text 'Create New Activity'
      end
    end
  end

  describe 'as a non-leader (member)' do
    let!(:quota) { create :quota, user: member, value: 20000, time_period: time_period }

    before do
      login_as member, scope: :user
      allow_any_instance_of(Api::DashboardsController).to receive(:time_period).and_return(time_period)
      visit '/'
      expect(page).to have_css('#dashboard')
    end

    scenario 'shows the stats box and open deals', js: true do
      within '#stats' do
        expect(find('.attainment')).to have_text '10% ATTAINMENT'
        expect(find('.quota')).to have_text '$20000 QUOTA'
        expect(find('.forecast')).to have_text '$2000 FORECAST'
        expect(find('.gap-to-goal')).to have_text '$18000 GAP TO GOAL'
      end

      within '#deals' do
        expect(page).to have_css '.table-wrapper'

        within 'table tbody' do
          expect(page).to have_css 'tr', count: 1
        end
      end
    end
  end
end
