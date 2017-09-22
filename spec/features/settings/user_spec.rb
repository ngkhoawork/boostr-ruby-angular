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

    it 'pops up a modal and adds new user', js: true do
      click_button('Add User')

      expect(page).to have_css('#user-modal')

      within '#user-modal' do
        fill_in 'first_name', with: 'Bobby'
        fill_in 'last_name', with: 'Jones'
        fill_in 'title', with: 'CEO'
        fill_in 'email', with: 'bobby@jones.com'

        find_button('Invite').trigger('click')
      end

      wait_for_ajax
      expect(page).to have_no_css('#user-modal')

      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 2)
        expect(page).to have_text('Bobby Jones')
      end
    end
  end

  describe 'updates users' do
    before do
      login_as user, scope: :user
      visit '/settings/users'
      expect(page).to have_css('#users')
    end

    it 'pops up an edit user modal and updates a user', js: true do
      within 'table tbody' do
        find('tr:first-child td:nth-child(2)').click
      end

      expect(page).to have_css('#user-modal')

      within '#user-modal' do
        fill_in 'first_name', with: 'Test'
        fill_in 'last_name', with: 'Person'
        fill_in 'title', with: 'Secretary'

        find_button('Update').trigger('click')
      end

      wait_for_ajax
      expect(page).to have_no_css('#user-modal')

      within 'table tbody' do
        expect(find('tr:first-child td:nth-child(1)')).to have_text('Test Person')
        expect(find('tr:first-child td:nth-child(3)')).to have_text('Secretary')
      end
    end
  end
end
