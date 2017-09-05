require 'rails_helper'

feature 'Accounts' do
  let(:company) { Company.first }
  let(:user) { create :user }

  describe 'showing account details' do
    before do
      set_client_type(client, company, 'Advertiser')
      set_client_type(agency, company, 'Agency')
      create_list :contact, 2, clients: [client, agency]
      create_list :deal, 2, advertiser: client, agency: agency
      login_as user, scope: :user
      visit "/accounts/#{client.id}"
      wait_for_ajax
    end

    it 'shows client details, people, deals, team and splits', js: true do
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

    it 'pops up a new client modal and creates a new client', js: true do
      find('add-button', text: 'Add Account').trigger('click')
      expect(page).to have_css('#client_modal')

      within '#client_modal' do
        ui_select('client-type', 'Agency')
        fill_in 'name', with: 'Bobby'

        find_button('Create').trigger('click')
        wait_for_ajax
      end

      expect(page).to have_css('tbody tr', count: 1)
      expect(page).to have_css('tbody tr', text: 'Bobby')
    end
  end

  describe 'deleting a client' do
    let!(:clients) { create_list :client, 3, created_by: user.id }

    before do
      login_as user, scope: :user
      visit '/accounts'
      wait_for_ajax
    end

    it 'removes the client from the page and navigates to the client index', js: true do
      expect(page).to have_css('tbody tr', count: 3)

      find_link(clients.first.name).trigger('click')

      find('.delete-deal').trigger('click')

      expect(page).to have_css('tbody tr', count:2)
    end
  end

  describe 'adding a contact to a client' do
    let!(:client) { create :client, created_by: user.id }
    let!(:contact) { create :contact, address_attributes: attributes_for(:address) }

    before do
      set_client_type(client, company, 'Advertiser')
      login_as user, scope: :user
      visit "/accounts/#{client.id}"
      wait_for_ajax
    end

    it 'with a new contact', js: true do
      find('.contacts', text: 'Contacts', match: :first).find('.add-btn').trigger('click')
      expect(page).to have_css('#contact_modal')

      within '#contact_modal' do
        fill_in 'name', with: 'Bobby'
        fill_in 'email', with: 'bobby123@boostrcrm.com'
        fill_in 'position', with: 'CEO'
        find('.btn.add-btn').trigger('click')
        fill_in 'street1', with: '123 Any Street'
        fill_in 'city', with: 'Boise'
        ui_select('state', 'Idaho')
        fill_in 'zip', with: '12365'
        fill_in 'office', with: '1234567890'
        fill_in 'mobile', with: '1257763562'

        find_button('Create').trigger('click')
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
    let!(:client) { create :client, created_by: user.id }
    let!(:agency) { create :client, created_by: user.id }

    let!(:open_stage) { create :stage, position: 1 }
    let!(:deal_type_sponsorship_option) { create :option, field: deal_type_field(company), name: 'Sponsorship' }
    let!(:deal_source_rfp_option) { create :option, field: deal_source_field(company), name: 'RFP Response to Agency' }

    before do
      set_client_type(client, company, 'Advertiser')
      set_client_type(agency, company, 'Agency')
      login_as user, scope: :user
      visit "/accounts/#{client.id}"
    end

    it 'with a new deal', js: true do
      find('.deals add-button').trigger('click')

      expect(page).to have_css('#deal_modal')

      within '#deal_modal' do
        fill_in 'name', with: 'Apple Watch Launch'
        ui_select('stage', open_stage.name)

        find('[name=start-date]').click
        find('ul td button', match: :first).trigger('click')
        find('[name=end-date]').click
        find('ul td button', match: :first).trigger('click')

        find_button('Create').trigger('click')
        wait_for_ajax
      end

      expect(page).to have_no_css('#deal_modal')
      expect(page).to have_text('Apple Watch Launch')
    end
  end

  private

  def client
    @_client ||= create :client, created_by: user.id, name: 'Apple'
  end

  def agency
    @agency ||= create :client, created_by: user.id, name: 'Blitz'
  end
end
