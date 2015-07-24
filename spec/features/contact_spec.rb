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
        ui_select('client', client.name)
        fill_in 'street1', with: '123 Any Street'
        fill_in 'city', with: 'Boise'
        ui_select('state', 'Idaho')
        fill_in 'zip', with: '12365'
        fill_in 'office', with: '1234567890'
        fill_in 'mobile', with: '1257763562'

        click_on 'Create'
      end

      expect(page).to have_no_css('#contact_modal')

      within '.list-group' do
        expect(page).to have_css('.list-group-item.active')
        expect(find('.list-group-item.active h4')).to have_text('Bobby')
      end

      within '#contact-detail' do
        expect(find('h2')).to have_text('Bobby')
      end

      click_link('New Person')

      expect(page).to have_css('#contact_modal')

      within '#contact_modal' do
        fill_in 'name', with: 'Johnny'
        fill_in 'position', with: 'CFO'
        ui_select('client', client.name)
        fill_in 'street1', with: '123 Any Road'
        fill_in 'city', with: 'Seattle'
        ui_select('state', 'Washington')
        fill_in 'zip', with: '78512'
        fill_in 'office', with: '(789) 125-8416'
        fill_in 'mobile', with: '(125) 776-3562'

        click_on 'Create'
      end

      expect(page).to have_no_css('#contact_modal')

      within '.list-group' do
        expect(page).to have_css('.list-group-item.active')
        expect(find('.list-group-item.active h4')).to have_text('Johnny')
      end

      within '#contact-detail' do
        expect(find('h2')).to have_text('Johnny')
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

    scenario 'pops up an edit contact modal and updates a contact' do
      click_link('edit-contact')
      expect(page).to have_css('#contact_modal')

      within '#contact_modal' do
        ui_select('client', client.name)
        fill_in 'name', with: 'Bobby'
        fill_in 'position', with: 'CEO'
        fill_in 'street1', with: '123 Main St.'
        fill_in 'city', with: 'Boise'
        ui_select('state', 'Idaho')

        click_on 'Update'
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
end
