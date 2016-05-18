require 'rails_helper'

feature 'Contacts' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let!(:client) { create :client, company: company }
  let!(:client_member) { create :client_member, client: client, user: user, values: [create_member_role(company)] }

  describe 'creating a contact' do
    before do
      login_as user, scope: :user
      visit '/people'
      expect(page).to have_css('#contacts')
    end

    scenario 'pops up a new contact modal and creates a new contact', js: true do
      find_link('New Person').trigger('click')
      expect(page).to have_css('#contact_modal')

      within '#contact_modal' do
        fill_in 'name', with: 'Bobby'
        fill_in 'email', with: 'abc123@boostrcrm.com'
        fill_in 'position', with: 'CEO'
        ui_select('client', client.name)
        fill_in 'street1', with: '123 Any Street'
        fill_in 'city', with: 'Boise'
        ui_select('state', 'Idaho')
        fill_in 'zip', with: '12365'
        fill_in 'office', with: '1234567890'
        fill_in 'mobile', with: '1257763562'

        find_button('Create').trigger('click')
      end

      expect(page).to have_no_css('#contact_modal')

      within '.list-group' do
        expect(page).to have_css('.list-group-item.active')
        expect(find('.list-group-item.active h4')).to have_text('Bobby')
      end

      within '#contact-detail' do
        expect(find('h2.contact-name')).to have_text('Bobby')
      end

      find_link('New Person').trigger('click')

      expect(page).to have_css('#contact_modal')

      within '#contact_modal' do
        fill_in 'name', with: 'Johnny'
        fill_in 'email', with: 'abc123@boostrcrm.com'
        fill_in 'position', with: 'CFO'
        ui_select('client', client.name)
        fill_in 'street1', with: '123 Any Road'
        fill_in 'city', with: 'Seattle'
        ui_select('state', 'Washington')
        fill_in 'zip', with: '78512'
        fill_in 'office', with: '(789) 125-8416'
        fill_in 'mobile', with: '(125) 776-3562'

        find_button('Create').trigger('click')
      end

      expect(page).to have_no_css('#contact_modal')

      within '.list-group' do
        expect(page).to have_css('.list-group-item.active')
        expect(find('.list-group-item.active h4')).to have_text('Johnny')
      end

      within '#contact-detail' do
        expect(find('h2.contact-name')).to have_text('Johnny')
      end
    end
  end

  describe 'Editing a contact' do
    let!(:contacts) { create_list :contact, 3, company: company, client: client }

    before do
      login_as user, scope: :user
      visit '/people'
      expect(page).to have_css('#contacts')
    end

    scenario 'pops up an edit contact modal and updates a contact', js: true do
      find_link('edit-contact').trigger('click')
      expect(page).to have_css('#contact_modal')

      within '#contact_modal' do
        ui_select('client', client.name)
        fill_in 'name', with: 'Bobby'
        fill_in 'email', with: 'abc123@boostrcrm.com'
        fill_in 'position', with: 'CEO'
        fill_in 'street1', with: '123 Main St.'
        fill_in 'city', with: 'Boise'
        ui_select('state', 'Idaho')

        find_button('Update').trigger('click')
      end

      expect(page).to have_no_css('#contact_modal')

      within '.list-group' do
        expect(page).to have_css('.list-group-item.active')
        expect(find('.list-group-item.active h4')).to have_text('Bobby')
      end

      within '#contact-detail' do
        expect(find('h2.contact-name')).to have_text('Bobby')
        expect(find('h2.contact-name')).to have_text('CEO')
      end
    end
  end

  describe 'Deleting a contact' do
    let!(:address) { create :address, email: 'abc123@boostrcrm.com' }
    let!(:contacts) { create_list :contact, 3, company: company, client: client, address: address }

    before do
      contacts.sort_by!(&:name)
      login_as user, scope: :user
      visit '/people'
      expect(page).to have_css('#contacts')
    end

    scenario 'removes the contact from the page and navigates to the contact index', js: true do
      within '.list-group' do
        expect(page).to have_css('.list-group-item', count: 3)
        find('.list-group-item:last-child').trigger('click')
      end

      within '#contact-detail' do
        expect(find('h2.contact-name')).to have_text(contacts[2].name)
        find('#delete-contact').trigger('click')
      end

      expect(page).to have_css('.list-group-item', count: 2)

      within '#contact-detail' do
        expect(find('h2.contact-name')).to have_text(contacts[0].name)
        find('#delete-contact').trigger('click')
      end

      expect(page).to have_css('.list-group-item', count: 1)
    end
  end
end
