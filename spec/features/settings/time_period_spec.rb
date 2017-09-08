require 'rails_helper'

feature 'TimePeriod' do
  let(:company) { create :company }
  let(:user) { create :user }

  describe 'creating a time_period' do
    before do
      login_as user, scope: :user
      visit '/settings/time_periods'
      expect(page).to have_css('#time-periods')
    end

    xit 'pops up a new time_period modal and creates a new time_period', js: true do
      find('add-button', text: 'Add').trigger('click')
      expect(page).to have_css('#time-period-modal')

      within '#time-period-modal' do
        fill_in 'name', with: 'Q1'
        fill_in 'start-date', with: '1/1/15'
        fill_in 'end-date', with: '3/31/15'

        find_button('Create').trigger('click')
      end

      expect(page).to have_no_css('#time-period-modal')

      within 'table tbody' do
        expect(page).to have_css('tr', count: 1)
      end
    end
  end

  describe 'deleting a time period' do
    let!(:time_periods) { create_list :time_period, 3 }

    before do
      login_as user, scope: :user
      visit '/settings/time_periods/'
      expect(page).to have_css('#time-periods')
    end

    xit 'removes the time_period from the page', js: true do
      within 'table tbody' do
        expect(page).to have_css('tr', count: 3)

        find('tr:first-child').hover

        within 'tr:first-child' do
          find('a', visible: false).trigger('click')
        end

        expect(page).to have_css('tr', count: 2)
      end
    end
  end
end
