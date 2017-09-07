require 'rails_helper'

feature 'Contacts' do
  describe 'creating a contact' do
    before do
      login_as user, scope: :user
      visit '/contacts'
    end

    xit 'pops up a new contact modal and creates a new contact', js: true do
      find('add-button').trigger('click')
      expect(page).to have_css('#contact_modal')

      within '#contact_modal' do
        fill_in 'name', with: 'Bobby'
        fill_in 'email', with: 'abc12345@boostrcrm.com'
        fill_in 'position', with: 'CEO'
        ui_select('client', client.name)
        find('.btn.add-btn').trigger('click')
        fill_in 'street1', with: '123 Any Street'
        fill_in 'city', with: 'Boise'
        ui_select('state', 'Idaho')
        fill_in 'zip', with: '12365'
        fill_in 'office', with: '1234567890'
        fill_in 'mobile', with: '1257763562'

        find_button('Create').trigger('click')
      end

      expect(page).to have_no_css('#contact_modal')
      expect(find('.detail-stats')).to have_text('Bobby')
      expect(find('.contact-info')).to have_text(client.name)
    end
  end

  describe 'Editing a contact' do
    before do
      login_as user, scope: :user
      visit "/contacts/#{contact.id}"
    end

    xit 'pops up an edit contact modal and updates a contact', js: true do
      find('.detail-stats .edit-deal').trigger('click')
      expect(page).to have_css('#contact_modal')

      within '#contact_modal' do
        ui_select('client', client.name)
        fill_in 'name', with: 'Bob'
        fill_in 'email', with: 'abc123@boostrcrm.com'
        fill_in 'position', with: 'CTO'
        fill_in 'street1', with: '123 Main St.'
        fill_in 'city', with: 'Boise'

        find_button('Update').trigger('click')
      end

      expect(page).to have_no_css('#contact_modal')
      expect(find('.detail-stats')).to have_text('Bob')
      expect(find('.contact-info')).to have_text('abc123@boostrcrm.com')
      expect(find('.contact-info')).to have_text('123 Main St.')
      expect(find('.contact-info')).to have_text('Boise')
    end
  end

  describe 'Deleting a contact' do
    before do
      login_as user, scope: :user
      visit "/contacts/#{contact.id}"
    end

    xit 'removes the contact from the page and navigates to the contact index', js: true do
      expect(page.current_path).to eq "/contacts/#{contact.id}"

      find('.detail-stats .delete-deal').trigger('click')

      wait_for_ajax

      expect(page.current_path).to eq '/contacts'
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end

  def client
    @_client ||= create :client, company: company, client_members: [client_member]
  end

  def client_member
    @_client_member ||= create :client_member, user: user, values: [create_member_role(company)]
  end

  def contact
    @_contact ||= create :contact, company: company, clients: [client]
  end
end
