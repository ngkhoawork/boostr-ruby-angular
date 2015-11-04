require 'rails_helper'

feature 'Forecast' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:parent) { create :parent_team, company: company, leader: user }
  let!(:time_period) { create :time_period, company: company }
  let!(:another_time_period) { create :time_period, company: company, name: 'Y2' }
  let!(:child) { create :child_team, company: company, parent: parent }
  let!(:member) { create :user, company: company, team: child }
  let(:stage) { create :stage, company: company, probability: 100 }
  let(:deal) { create :deal, company: company, stage: stage, start_date: "2015-01-01", end_date: "2015-12-31"  }
  let!(:deal_member) { create :deal_member, deal: deal, user: member, share: 100 }
  let!(:deal_product) { create_list :deal_product, 4, deal: deal, budget: 2500, start_date: "2015-01-01", end_date: "2015-01-31" }

  describe 'showing the root level of teams' do

    before do
      login_as user, scope: :user
      visit '/forecast'
      expect(page).to have_css('#forecasts')
    end

    scenario 'shows the parent team name and drills down teams and changes time periods', js: true do
      within '.table-wrapper' do
        expect(page).to have_css('tr', count: 2)

        within '.teams tr:last-child' do
          expect(find('td:first-child')).to have_text parent.name
          find('td:first-child a').trigger('click')
          expect(find('td:first-child')).to have_text child.name
          find('td.weighted-pipeline a').trigger('click')
        end

        within 'tr.weighted-pipeline-detail table tbody' do
          expect(page).to have_css 'tr', count: 1
        end
      end

      within '.quota-period' do
        find('a').trigger('click')
        find('.time-periods li:last-child a').trigger('click')
        expect(page).to have_text 'Y2'
      end

      within '.table-wrapper' do
        expect(page).to have_css('tr', count: 2)

        within '.teams tr:first-child' do
          expect(find('td:first-child')).to have_text child.name
          find('td:first-child a').trigger('click')
        end

        within '.members tr:first-child' do
          expect(find('td:first-child')).to have_text member.name
          find('td.weighted-pipeline a').trigger('click')
        end

        within 'tr.weighted-pipeline-detail table tbody' do
          expect(page).to have_css 'tr', count: 1
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

    scenario 'shows the current_user\'s forecast data', js: true do
      within '.table-wrapper' do
        expect(page).to have_css('tr', count: 2)

        within '.member tr:last-child' do
          expect(find('td:first-child')).to have_text member.name
        end
      end
    end
  end
end
