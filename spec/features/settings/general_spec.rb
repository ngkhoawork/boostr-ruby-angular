require 'rails_helper'

feature 'Custom Values' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  describe 'settings page' do
    before do
      login_as user, scope: :user
      visit '/settings/general'
      expect(page).to have_css('#general')
    end

    it 'shows WoW snapshot setting', js: true do
      within '#general' do
        expect(page).to have_text 'Sunday'
        ui_select('day', 'Tuesday')

        within '.ui-select-match-text' do
          expect(page).to have_text 'Tuesday'
        end
      end
    end
  end
end
