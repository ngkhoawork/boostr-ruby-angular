require 'rails_helper'

feature 'Clients' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  describe 'showing client details' do
    let!(:client) { create :advertiser, company: company }
    let!(:agency) { create :agency, company: company }
    let!(:contacts) { create_list :contact, 2, client: client, company: company }
    let!(:deal) { create_list :deal, 2, company: company, advertiser: client }
    let!(:agency_deal) { create :deal, company: company, agency: agency }

    before do
      login_as user, scope: :user
      visit "/clients/#{client.id}"
      expect(page).to have_css('#clients')
    end

    scenario 'shows client details, people, deals, team and splits' do
      within '#client-list' do
        expect(page).to have_css('.list-group-item', count: 2)
      end

      within '#client-detail' do
        expect(find('h2.client-name')).to have_text(client.name)

        within '#people' do
          expect(page).to have_css('.well', count: 2)
        end

        within '#deals' do
          expect(page).to have_css('.well', count: 2)
        end

        within '#teamsplits' do
          expect(page).to have_css('.table-wrapper')
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

  describe 'editing a client' do
    let!(:clients) { create_list :advertiser, 3, company: company }

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

  describe 'deleting a client' do
    let!(:clients) { create_list :advertiser, 3, company: company }

    before do
      clients.sort_by!(&:name)
      login_as user, scope: :user
      visit '/clients'
      expect(page).to have_css('#clients')
    end

    scenario 'removes the client from the page and navigates to the client index' do
      within '.list-group' do
        expect(page).to have_css('.list-group-item', count: 3)
        find('.list-group-item:last-child').click
      end

      within '#client-detail' do
        expect(find('h2.client-name')).to have_text(clients[2].name)
        find('#delete-client').click
      end

      page.driver.browser.switch_to.alert.accept

      expect(page).to have_css('.list-group-item', count: 2)

      within '#client-detail' do
        expect(find('h2.client-name')).to have_text(clients[0].name)
        find('#delete-client').click
      end

      page.driver.browser.switch_to.alert.accept

      expect(page).to have_css('.list-group-item', count: 1)
    end
  end

  describe 'adding a contact to a client' do
    let!(:client) { create :advertiser, company: company }
    let!(:contact) { create :contact, company: company, address_attributes: attributes_for(:address) }

    before do
      login_as user, scope: :user
      visit '/clients'
      expect(page).to have_css('#clients')
    end

    scenario 'with a new contact' do
      find('.add-contact').click
      expect(page).to have_css('.new-contact-options', visible: true)
      find('.new-person').click
      expect(page).to have_css('#contact_modal')

      within '#contact_modal' do
        fill_in 'name', with: 'Bobby'
        fill_in 'position', with: 'CEO'
        fill_in 'street1', with: '123 Any Street'
        fill_in 'city', with: 'Boise'
        ui_select('state', 'Idaho')
        fill_in 'zip', with: '12365'
        fill_in 'office', with: '1234567890'
        fill_in 'mobile', with: '1257763562'

        click_on 'Create'
      end

      expect(page).to have_no_css('#contact_modal')

      within '#people' do
        expect(page).to have_css('.well', count: 1)

        within '.well:first-child' do
          expect(page).to have_text('Bobby, CEO')
        end
      end
    end

    scenario 'with an existing contact' do
      find('.add-contact').click

      expect(page).to have_css('.new-contact-options', visible: true)
      find('.existing-contact').click

      expect(page).to have_css('.existing-contact-options', visible: true)
      ui_select('contact-list', contact.name)

      within '#people' do
        expect(page).to have_css('.well', count: 1)

        within '.well:first-child' do
          expect(page).to have_text(contact.name)
        end
      end
    end
  end

  describe 'adding a deal to a client' do
    let!(:client) { create :advertiser, company: company }
    let!(:agency) { create :agency, company: company }
    let!(:open_stage) { create :stage, company: company, position: 1 }

    before do
      login_as user, scope: :user
      visit '/clients'
      expect(page).to have_css('#clients')
    end

    scenario 'with a new deal' do
      find('.new-deal').click

      expect(page).to have_css('#deal_modal')

      within '#deal_modal' do
        fill_in 'name', with: 'Apple Watch Launch'
        ui_select('stage', open_stage.name)
        fill_in 'budget', with: '1234'
        ui_select('advertiser', client.name)
        ui_select('agency', agency.name)
        ui_select('deal-type', 'Sponsorship')
        ui_select('source-type', 'RFP Response to Agency')
        fill_in 'next-steps', with: 'Meet with Rep'
        fill_in 'start-date', with: '1/1/15'
        fill_in 'end-date', with: '12/31/15'

        click_on 'Create'
      end

      expect(page).to have_no_css('#deal_modal')
      expect(page).to have_css('#deal')
    end
  end
end
