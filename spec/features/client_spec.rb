require 'rails_helper'

feature 'Accounts' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  describe 'showing account details' do
    before do
      set_client_type(client, company, 'Advertiser')
      set_client_type(agency, company, 'Agency')
      create_list :contact, 2, company: company, clients: [client, agency]
      create_list :deal, 2, advertiser: client, agency: agency, company: company
      login_as user, scope: :user
      visit "/accounts/#{client.id}"
      wait_for_ajax
    end

    xit 'shows client details, people, deals, team and splits', js: true do
      within '.client-title' do
        expect(page).to have_text(client.name)
      end

      within '.members' do
        expect(page).to have_css('tbody tr', count: 1)
      end

      within('.deals', text: 'Deals') do
        expect(page).to have_css('tbody tr', count: 2)
      end
    end
  end

  describe 'creating a client' do
    before do
      login_as user, scope: :user
      visit '/accounts'
      wait_for_ajax
    end

    xit 'pops up a new client modal and creates a new client', js: true do
      find('add-button', text: 'Add Account').click
      expect(page).to have_css('#client_modal')

      within '#client_modal' do
        ui_select('client-type', 'Agency')
        fill_in 'name', with: 'Bobby'

        find_button('Create').click
        wait_for_ajax
      end

      expect(page).to have_css('tbody tr', count: 1)
      expect(page).to have_css('tbody tr', text: 'Bobby')
    end
  end

  describe 'deleting a client' do
    let!(:clients) { create_list :client, 3, created_by: user.id, company: company }

    before do
      login_as user, scope: :user
      visit '/accounts'
      wait_for_ajax
    end

    xit 'removes the client from the page and navigates to the client index', js: true do
      expect(page).to have_css('tbody tr', count: 3)

      find_link(clients.first.name).click

      find('.delete-deal').click

      expect(page).to have_css('tbody tr', count:2)
    end
  end

  describe 'adding a contact to a client' do
    let!(:client) { create :client, created_by: user.id, company: company }
    let!(:contact) { create :contact, company: company, address_attributes: attributes_for(:address) }

    before do
      set_client_type(client, company, 'Advertiser')
      login_as user, scope: :user
      visit "/accounts/#{client.id}"
      wait_for_ajax
    end

    xit 'with a new contact', js: true do
      find('.contacts', text: 'Contacts', match: :first).find('.add-btn').click
      expect(page).to have_css('#contact_modal')

      within '#contact_modal' do
        fill_in 'name', with: 'Bobby'
        fill_in 'email', with: 'bobby123@boostrcrm.com'
        fill_in 'position', with: 'CEO'
        find('.btn.add-btn').click
        sleep 3
        fill_in 'street1', with: '123 Any Street'
        fill_in 'city', with: 'Boise'
        ui_select('state', 'Idaho')
        fill_in 'zip', with: '12365'
        fill_in 'office', with: '1234567890'
        fill_in 'mobile', with: '1257763562'

        find_button('Create').click
        wait_for_ajax
      end

      expect(page).to have_no_css('#contact_modal')

      within '.contacts', text: 'Contacts', match: :first do
        expect(page).to have_css('tbody tr', count: 1)
        expect(page).to have_text('Bobby')
      end
    end
  end

  describe 'adding a deal to a client' do
    let!(:client) { create :client, created_by: user.id, company: company }
    let!(:agency) { create :client, created_by: user.id, company: company }

    let!(:open_stage) { create :stage, position: 1, company: company }
    let!(:deal_type_sponsorship_option) { create :option, field: deal_type_field(company), name: 'Sponsorship', company: company }
    let!(:deal_source_rfp_option) { create :option, field: deal_source_field(company), name: 'RFP Response to Agency', company: company }

    before do
      set_client_type(client, company, 'Advertiser')
      set_client_type(agency, company, 'Agency')
      login_as user, scope: :user
      visit "/accounts/#{client.id}"
    end

    xit 'with a new deal', js: true do
      find('.deals add-button').click

      expect(page).to have_css('#deal_modal')

      within '#deal_modal' do
        find("input[placeholder='Name']").set 'Apple Watch Launch'
        ui_select('stage', open_stage.name)

        find('[name=start-date]').click
        find('ul td button', match: :first).click

        find('[name=end-date]').click
        find('ul td button', match: :first).click

        find_button('Create').click
        wait_for_ajax
      end

      expect(page).to have_no_css('#deal_modal')
      expect(page).to have_text('Apple Watch Launch')
    end
  end

  private

  def client
    @_client ||= create :client, created_by: user.id, name: 'Apple', company: company
  end

  def agency
    @agency ||= create :client, created_by: user.id, name: 'Blitz', company: company
  end
end
