require 'rails_helper'

feature 'Forecast' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:parent) { create :parent_team, company: company, leader: user }
  let!(:time_period) { create :time_period, company: company }
  let!(:another_time_period) { create :time_period, company: company, name: 'Y2' }
  let!(:child) { create :child_team, company: company, parent: parent }
  let!(:member) { create :user, company: company, team: child }

  describe 'showing the root level of teams' do

    before do
      login_as user, scope: :user
      visit '/forecast'
      expect(page).to have_css('#forecasts')
    end

    scenario 'shows the parent team name and drills down teams and changes time periods' do
      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 1)

        within 'tr:first-child' do
          expect(find('td:first-child')).to have_text parent.name
          find('td:first-child a').click
          expect(find('td:first-child')).to have_text child.name
        end
      end

      within '.quota-period' do
        find('a').click

        within('.dropdown-menu') do
          find('li:last-child a').click
        end

        expect(page).to have_text 'Y2'
      end

      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 1)

        within 'tr:first-child' do
          expect(find('td:first-child')).to have_text child.name
          find('td:first-child a').click
          expect(find('td:first-child')).to have_text member.full_name
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

    scenario 'shows the current_user\'s forecast data' do
      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 1)

        within 'tr:first-child' do
          expect(find('td:first-child')).to have_text member.full_name
        end
      end
    end
  end
end
