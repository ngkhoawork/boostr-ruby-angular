require 'rails_helper'

feature 'Users' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  describe 'inviting a new user' do

    before do
      login_as user, scope: :user
      visit "/settings/users"
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
    end
  end
end