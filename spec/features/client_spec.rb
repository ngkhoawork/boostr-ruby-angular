require 'rails_helper'

feature 'Clients' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  before do
    login_as user, scope: :user
    visit '/clients'
    expect(page).to have_css('#clients')
  end

  describe 'subnav' do
    scenario 'pops up a new client modal and creates a new client' do
      click_link('New Client')
      expect(page).to have_css('#client_modal')

      within '#client_modal' do
        fill_in 'name', with: 'Bobby'
        click_on 'Create'
      end

      expect(page).to have_no_css('#client_modal')

      within '.list-group' do
        expect(page).to have_css('.list-group-item.active')
        expect(find('.list-group-item.active strong')).to have_text('Bobby')
      end

      click_link('New Client')
      expect(page).to have_css('#client_modal')

      within '#client_modal' do
        fill_in 'name', with: 'Johnny'
        click_on 'Create'
      end

      expect(page).to have_no_css('#client_modal')

      within '.list-group' do
        expect(page).to have_css('.list-group-item.active')
        expect(find('.list-group-item.active strong')).to have_text('Johnny')
      end

      within '#client-detail' do
        expect(find('h3')).to have_text('Johnny')
      end

    end
  end

end