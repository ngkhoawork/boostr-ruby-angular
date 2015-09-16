require 'rails_helper'

feature 'Forecast' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:parent) { create :parent_team, company: company, leader: user }
  let!(:child) { create :child_team, company: company, parent: parent }
  let!(:member) { create :user, company: company, team: child }


  describe 'showing the root level of teams' do

    before do
      login_as user, scope: :user
      visit '/forecast'
      expect(page).to have_css('#forecasts')
    end

    scenario 'shows the parent team name' do
       within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 1)

        within 'tr:first-child' do
          expect(find('td:first-child')).to have_text parent.name
          find('td:first-child a').click
          expect(find('td:first-child')).to have_text child.name
          find('td:first-child a').click
          expect(find('td:first-child')).to have_text member.full_name
        end
      end
    end
  end
end