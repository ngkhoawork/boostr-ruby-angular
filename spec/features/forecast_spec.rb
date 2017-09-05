require 'rails_helper'

feature 'Forecast' do
  let(:company) { Company.first }
  let(:user) { create :user }
  let(:parent) { create :parent_team, leader: user }
  let!(:time_period) { create :time_period }
  let!(:another_time_period) { create :time_period, name: 'Y2' }
  let!(:child) { create :child_team, parent: parent }
  let!(:member) { create :user, team: child }
  let(:stage) { create :stage, probability: 100 }
  let(:deal) { create :deal, stage: stage, start_date: "2015-01-01", end_date: "2015-12-31"  }
  let!(:deal_member) { create :deal_member, deal: deal, user: member, share: 100 }
  let!(:deal_product_budget) { create_list :deal_product_budget, 4, budget: 2500, start_date: "2015-01-01", end_date: "2015-01-31" }

  describe 'showing the root level of teams' do
    before do
      login_as user, scope: :user
      visit '/forecast'
      expect(page).to have_css('#forecasts')
    end

    it 'shows the parent team name and drills down teams and changes time periods', js: true do
      within '.table-wrapper' do
        expect(page).to have_css('tr', count: 2)

        within '.teams tr:last-child' do
          expect(find('td:first-child')).to have_text parent.name
          find('td:first-child a').trigger('click')
          expect(find('td:first-child')).to have_text child.name
        end

      end

      within '.quota-period' do
        find('a').trigger('click')
        find('.time-periods li:nth-child(1) a').trigger('click')
      end
      expect(page).to have_text 'Y2'

      within '.table-wrapper' do
        expect(page).to have_css('tr', count: 2)

        within '.teams tr:first-child' do
          expect(find('td:first-child')).to have_text child.name
          find('td:first-child a').trigger('click')
        end

        within '.members tr:first-child' do
          expect(find('td:first-child')).to have_text member.name
        end

      end

      within '.quota-period' do
        expect(page).to have_text 'Y2'
      end
    end
  end

  describe 'showing only the member (non-leader) forecast' do
    before do
      login_as member, scope: :user
      visit '/forecast'
      expect(page).to have_css('#forecasts')
    end

    it 'shows the current_user\'s forecast data', js: true do
      within '.table-wrapper' do
        expect(page).to have_css('tr', count: 2)

        click_on parent.name
        click_on child.name

        within '.members' do
          expect(page).to have_text member.name
        end
      end
    end
  end
end
