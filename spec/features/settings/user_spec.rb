require 'rails_helper'

feature 'Users' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  describe 'inviting a new user' do
    before do
      login_as user, scope: :user
      visit '/settings/users'
      expect(page).to have_css('#users')
    end

    scenario 'pops up a modal and sends the user an email' do
      find('.add-user').click

      expect(page).to have_css('#user-modal')

      within '#user-modal' do
        fill_in 'first_name', with: 'Bobby'
        fill_in 'last_name', with: 'Jones'
        fill_in 'email', with: 'bobby@jones.com'

        click_on 'Invite'
      end

      expect(page).to have_no_css('#user-modal')

      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 2)
      end
    end
  end

  describe 'update the user' do
    let!(:users) { create_list :user, 3, company: company }

    before do
      login_as user, scope: :user
      visit '/settings/users'
      expect(page).to have_css('#users')
    end

    scenario 'pops up an edit user modal and updates a user' do
      within 'table tbody' do
        find('tr:first-child').click
      end

      expect(page).to have_css('#user-modal')

      within '#user-modal' do
        fill_in 'first_name', with: 'Test'
        fill_in 'last_name', with: 'Person'

        click_on 'Update'
      end

      expect(page).to have_no_css('#user-modal')

      within '.table-wrapper' do
        within(:xpath, './/table/tbody/tr[1]/td[2]') do
          expect(page).to have_text('Test Person')
        end
      end
    end
  end
end
