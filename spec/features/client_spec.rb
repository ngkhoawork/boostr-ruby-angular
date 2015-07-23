require 'rails_helper'

feature 'Clients' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  describe 'showing client details' do
    let!(:client) { create :client, company: company }
    let!(:contacts) { create_list :contact, 3, client: client, company: company }

    before do
      login_as user, scope: :user
      visit "/clients/#{client.id}"
      expect(page).to have_css('#clients')
    end

    scenario 'shows client details and people' do
      within '#client-detail' do
        expect(find('h2.client-name')).to have_text(client.name)

        within '#people' do
          expect(page).to have_css('.well', count: 3)
        end
      end
    end
  end


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
        ui_select('client-type', 'Agency')
        fill_in 'name', with: 'Bobby'
        fill_in 'street1', with: '123 Main St.'
        fill_in 'city', with: 'Boise'
        ui_select('state', 'Idaho')

        click_on 'Create'
      end

      expect(page).to have_no_css('#client_modal')

      within '.list-group' do
        expect(page).to have_css('.list-group-item.active')
        expect(find('.list-group-item.active h4')).to have_text('Bobby')
      end

      within '#client-detail' do
        expect(find('h2.client-name')).to have_text('Bobby')
        expect(find('h2.client-name')).to have_text('Boise, ID')
      end

      click_link('New Client')
      expect(page).to have_css('#client_modal')

      within '#client_modal' do
        ui_select('client-type', 'Agency')
        fill_in 'name', with: 'Johnny'
        fill_in 'street1', with: '123 Main St.'
        fill_in 'city', with: 'Seattle'
        ui_select('state', 'Washington')
        click_on 'Create'
      end

      expect(page).to have_no_css('#client_modal')

      within '.list-group' do
        expect(page).to have_css('.list-group-item.active')
        expect(find('.list-group-item.active h4')).to have_text('Johnny')
      end

      within '#client-detail' do
        expect(find('h2.client-name')).to have_text('Johnny')
        expect(find('h2.client-name')).to have_text('Seattle, WA')
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
        ui_select('client-type', 'Agency')
        fill_in 'name', with: 'Bobby'
        fill_in 'street1', with: '123 Main St.'
        fill_in 'city', with: 'Boise'
        ui_select('state', 'Idaho')

        click_on 'Update'
      end

      expect(page).to have_no_css('#client_modal')

      within '.list-group' do
        expect(page).to have_css('.list-group-item.active')
        expect(find('.list-group-item.active h4')).to have_text('Bobby')
      end

      within '#client-detail' do
        expect(find('h2.client-name')).to have_text('Bobby')
        expect(find('h2.client-name')).to have_text('Boise, ID')
      end
    end
  end

  describe 'Deleting a client' do
    let!(:clients) { create_list :client, 3, company: company }

    before do
      login_as user, scope: :user
      visit '/clients'
      expect(page).to have_css('#clients')
    end

    scenario 'removes the client from the page and navigates to the client index' do
      within '.list-group' do
        expect(page).to have_css('.list-group-item', count: 3)
        find('.list-group-item:last-child').click()
      end

      within '#client-detail' do
        expect(find('h2.client-name')).to have_text(clients[2].name)
        find('#delete-client').click()
      end

      page.driver.browser.switch_to.alert.accept

      expect(page).to have_css('.list-group-item', count: 2)

      within '#client-detail' do
        expect(find('h2.client-name')).to have_text(clients[0].name)
        find('#delete-client').click()
      end

      page.driver.browser.switch_to.alert.accept

      expect(page).to have_css('.list-group-item', count: 1)
    end
  end

end