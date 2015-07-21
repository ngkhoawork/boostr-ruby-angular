require 'rails_helper'

feature 'Clients' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }


  describe 'creating a client' do
    before do
      login_as user, scope: :user
      visit '/clients'
      expect(page).to have_css('#clients')
    end

    scenario 'pops up a new client modal and creates a new client' do
      click_link('New Client')
      expect(page).to have_css('#client_modal')

      within '#client_modal' do
        fill_in 'name', with: 'Bobby'
        fill_in 'street1', with: '123 Main St.'
        fill_in 'city', with: 'Boise'
        ui_select('Idaho')

        click_on 'Create'
      end

      expect(page).to have_no_css('#client_modal')

      within '.list-group' do
        expect(page).to have_css('.list-group-item.active')
        expect(find('.list-group-item.active h4')).to have_text('Bobby')
      end

      within '#client-detail' do
        expect(find('h2')).to have_text('Bobby')
        expect(find('h2')).to have_text('Boise, ID')
      end

      click_link('New Client')
      expect(page).to have_css('#client_modal')

      within '#client_modal' do
        fill_in 'name', with: 'Johnny'
        fill_in 'street1', with: '123 Main St.'
        fill_in 'city', with: 'Seattle'
        ui_select('Washington')
        click_on 'Create'
      end

      expect(page).to have_no_css('#client_modal')

      within '.list-group' do
        expect(page).to have_css('.list-group-item.active')
        expect(find('.list-group-item.active h4')).to have_text('Johnny')
      end

      within '#client-detail' do
        expect(find('h2')).to have_text('Johnny')
        expect(find('h2')).to have_text('Seattle, WA')
      end

    end

  end
  describe 'Editing a client' do
    let!(:clients) { create_list :client, 3, company: company }

    before do
      login_as user, scope: :user
      visit '/clients'
      expect(page).to have_css('#clients')
    end

    scenario 'pops up an edit client modal and updates a client' do
      click_link('edit-client')
      expect(page).to have_css('#client_modal')

      within '#client_modal' do
        fill_in 'name', with: 'Bobby'
        fill_in 'street1', with: '123 Main St.'
        fill_in 'city', with: 'Boise'
        ui_select('Idaho')

        click_on 'Update'
      end

      expect(page).to have_no_css('#client_modal')

      within '.list-group' do
        expect(page).to have_css('.list-group-item.active')
        expect(find('.list-group-item.active h4')).to have_text('Bobby')
      end

      within '#client-detail' do
        expect(find('h2')).to have_text('Bobby')
        expect(find('h2')).to have_text('Boise, ID')
      end
    end
  end

end