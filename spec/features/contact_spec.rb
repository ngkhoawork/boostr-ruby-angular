require 'rails_helper'

feature 'Contacts' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let!(:client) { create :client, company: company }

  describe 'creating a contact' do
    before do
      login_as user, scope: :user
      visit '/people'
      expect(page).to have_css('#contacts')
    end

    scenario 'pops up a new contact modal and creates a new contact' do
      click_link('New Person')
      expect(page).to have_css('#contact_modal')

      within '#contact_modal' do
        fill_in 'name', with: 'Bobby'
        fill_in 'position', with: 'CEO'
        select client.name, from: 'client'
        fill_in 'street1', with: '123 Any Street'
        fill_in 'city', with: 'Boise'
        fill_in 'state', with: 'ID'
        fill_in 'zip', with: '12365'
        fill_in 'office', with: '1234567890'

        click_on 'Create'
      end

      expect(page).to have_no_css('#contact_modal')

      click_link('New Person')
      expect(page).to have_css('#contact_modal')

      within '#contact_modal' do
        fill_in 'name', with: 'Johnny'
        fill_in 'position', with: 'CFO'
        select client.name, from: 'client'
        fill_in 'street1', with: '123 Any Road'
        fill_in 'city', with: 'Seattle'
        fill_in 'state', with: 'WA'
        fill_in 'zip', with: '78512'
        fill_in 'office', with: '(789) 125-8416'

        click_on 'Create'
      end

    end

  end
end
