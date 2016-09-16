require 'rails_helper'

feature 'Clients' do
  let(:company) { Company.first }
  let(:user) { create :user }

  describe 'showing client details' do
    let!(:client) { create :client, created_by: user.id }
    let!(:agency) { create :client, created_by: user.id }
    let!(:contacts) { create_list :contact, 2, clients: [client] }
    let!(:deal) { create_list :deal, 2, advertiser: client }
    let!(:agency_deal) { create :deal, agency: agency }

    before do
      set_client_type(client, company, 'Advertiser')
      set_client_type(agency, company, 'Agency')
      login_as user, scope: :user
      visit "/clients/#{client.id}"
      expect(page).to have_css('#clients')
    end

    scenario 'shows client details, people, deals, team and splits', js: true do
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

    scenario 'pops up a new client modal and creates a new client', js: true do
      find_link('New Client').trigger('click')
      expect(page).to have_css('#client_modal')

      within '#client_modal' do
        ui_select('client-type', 'Agency')
        fill_in 'name', with: 'Bobby'
        fill_in 'street1', with: '123 Main St.'
        fill_in 'city', with: 'Boise'
        ui_select('state', 'Idaho')

        find_button('Create').trigger('click')
      end

      expect(page).to have_no_css('#client_modal')
      expect(page).to have_css('#client-list')

      within '.list-group' do
        expect(page).to have_css('.list-group-item.active')
        expect(find('.list-group-item.active h4')).to have_text('Bobby')
      end

      within '#client-detail' do
        expect(find('h2.client-name')).to have_text('Bobby')
        expect(find('h2.client-name')).to have_text('Boise, ID')
        expect(find('#details')).to have_text('Agency')
      end

      find_link('New Client').trigger('click')
      expect(page).to have_css('#client_modal')

      within '#client_modal' do
        ui_select('client-type', 'Agency')
        fill_in 'name', with: 'Johnny'
        fill_in 'street1', with: '123 Main St.'
        fill_in 'city', with: 'Seattle'
        ui_select('state', 'Washington')
        find_button('Create').trigger('click')
      end

      expect(page).to have_no_css('#client_modal')
      expect(page).to have_no_css('.no-client-members')
      expect(page).to have_css('.no-people')
      expect(page).to have_css('.no-deals')

      within '.list-group' do
        expect(page).to have_css('.list-group-item.active')
        expect(find('.list-group-item.active h4')).to have_text('Johnny')
      end

      within '#client-detail' do
        expect(find('h2.client-name')).to have_text('Johnny')
        expect(find('h2.client-name')).to have_text('Seattle, WA')
      end

      find_link('edit-client').trigger('click')
      expect(page).to have_css('#client_modal')

      within '#client_modal' do
        ui_select('client-type', 'Agency')
        fill_in 'name', with: 'Bedrock'
        fill_in 'street1', with: '123 Main St.'
        fill_in 'city', with: 'Boise'
        ui_select('state', 'Idaho')

        find_button('Update').trigger('click')
      end

      expect(page).to have_no_css('#client_modal')
      expect(page).to have_no_css('.no-client-members')
      expect(page).to have_css('.no-people')
      expect(page).to have_css('.no-deals')

      within '.list-group' do
        expect(page).to have_css('.list-group-item.active')
        expect(find('.list-group-item.active h4')).to have_text('Bedrock')
      end

      within '#client-detail' do
        expect(find('h2.client-name')).to have_text('Bedrock')
        expect(find('h2.client-name')).to have_text('Boise, ID')
      end
    end
  end

  describe 'deleting a client' do
    let!(:clients) { create_list :client, 3, created_by: user.id }

    before do
      clients.sort_by!(&:name)
      login_as user, scope: :user
      visit '/clients'
      expect(page).to have_css('#clients')
    end

    scenario 'removes the client from the page and navigates to the client index', js: true do
      within '.list-group' do
        expect(page).to have_css('.list-group-item', count: 3)
        find('.list-group-item:last-child').trigger('click')
      end

      within '#client-detail' do
        expect(find('h2.client-name')).to have_text(clients[2].name)
        find('#delete-client').trigger('click')
      end

      expect(page).to have_css('.list-group-item', count: 2)

      within '#client-detail' do
        expect(find('h2.client-name')).to have_text(clients[0].name)
        find('#delete-client').trigger('click')
      end

      expect(page).to have_css('.list-group-item', count: 1)

      expect(page).to have_no_css('.no-client-members')
      expect(page).to have_css('.no-people')
      expect(page).to have_css('.no-deals')
    end
  end

  describe 'adding a contact to a client' do
    let!(:client) { create :client, created_by: user.id }
    let!(:contact) { create :contact, address_attributes: attributes_for(:address) }

    before do
      set_client_type(client, company, 'Advertiser')
      login_as user, scope: :user
      visit '/clients'
      expect(page).to have_css('#clients')
    end

    scenario 'with a new contact', js: true do
      find('.add-contact').trigger('click')
      expect(page).to have_css('.new-contact-options', visible: true)
      find('.new-person').trigger('click')
      expect(page).to have_css('#contact_modal')

      within '#contact_modal' do
        fill_in 'name', with: 'Bobby'
        fill_in 'email', with: 'bobby123@boostrcrm.com'
        fill_in 'position', with: 'CEO'
        find('.add-address-btn').trigger('click')
        fill_in 'street1', with: '123 Any Street'
        fill_in 'city', with: 'Boise'
        ui_select('state', 'Idaho')
        fill_in 'zip', with: '12365'
        fill_in 'office', with: '1234567890'
        fill_in 'mobile', with: '1257763562'

        find_button('Create').trigger('click')
      end

      expect(page).to have_no_css('#contact_modal')

      within '#people' do
        expect(page).to have_css('.well', count: 1)

        within '.well:first-child' do
          expect(page).to have_text('Bobby, CEO')
        end
      end

      expect(page).to have_no_css('.no-client-members')
      expect(page).to have_css('.no-deals')
    end

    scenario 'with an existing contact', js: true do
      find('.add-contact').trigger('click')

      expect(page).to have_css('.new-contact-options', visible: true)
      find('.existing-contact').trigger('click')

      expect(page).to have_css('.existing-contact-options', visible: true)
      ui_select('contact-list', contact.name)

      within '#people' do
        expect(page).to have_css('.well', count: 1)

        within '.well:first-child' do
          expect(page).to have_text(contact.name)
        end
      end

      expect(page).to have_no_css('.no-client-members')
      expect(page).to have_css('.no-deals')
    end
  end

  describe 'adding a deal to a client' do
    let!(:client) { create :client, created_by: user.id }
    let!(:agency) { create :client, created_by: user.id }

    let!(:open_stage) { create :stage, position: 1 }
    let!(:deal_type_sponsorship_option) { create :option, field: deal_type_field(company), name: "Sponsorship" }
    let!(:deal_source_rfp_option) { create :option, field: deal_source_field(company), name: "RFP Response to Agency" }

    before do
      set_client_type(client, company, 'Advertiser')
      set_client_type(agency, company, 'Agency')
      login_as user, scope: :user
      visit '/clients'
      expect(page).to have_css('#clients')
    end

    scenario 'with a new deal', js: true do
      find('.new-deal').trigger('click')

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

        find_button('Create').trigger('click')
      end

      expect(page).to have_no_css('#deal_modal')
      expect(page).to have_css('#deal')
    end
  end

  describe 'adding a reminder to a client' do
    let!(:clients) { create_list :client, 3, created_by: user.id }

    before do
      clients.sort_by!(&:name)
      login_as user, scope: :user
      visit '/clients'
      expect(page).to have_css('#clients')
    end

    scenario 'creates reminder and edits it', js: true do
      within '.client-name' do
        expect(page).to have_css('.show-create-remainders-popup')

        find('.show-create-remainders-popup > label').trigger('click')
        expect(page).to have_text("Reminder name*")

        within '#reminder_modal' do
          fill_in 'name', with: 'Reminder!'
          fill_in 'comment', with: 'Client Reminder'

          find_button('Set Reminder').trigger('click')
        end

        expect(page).not_to have_css('#reminder_modal')

        find('.show-create-remainders-popup > label').trigger('click')
        expect(find("input[name='name']").value).to eq('Reminder!')

        within '#reminder_modal' do
          fill_in 'name', with: 'Reminder update!'
          find_button('Set Reminder').trigger('click')
        end

        expect(page).not_to have_css('#reminder_modal')

        find('.show-create-remainders-popup > label').trigger('click')
        expect(find("input[name='name']").value).to eq("Reminder update!")
      end
    end
  end
end
