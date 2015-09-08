require 'rails_helper'

feature 'TimePeriod' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  describe 'creating a contact' do
    before do
      login_as user, scope: :user
      visit '/settings/time_periods'
      expect(page).to have_css('#time-periods')
    end

    scenario 'pops up a new contact modal and creates a new contact' do
      click_link('Add Time Period')
      expect(page).to have_css('#time-period-modal')

      within '#time-period-modal' do
        fill_in 'name', with: 'Q1'
        fill_in 'start-date', with: '1/1/15'
        fill_in 'end-date', with: '3/31/15'

        click_on 'Create'
      end

      expect(page).to have_no_css('#time-period-modal')

      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 1)
      end
    end
  end
end