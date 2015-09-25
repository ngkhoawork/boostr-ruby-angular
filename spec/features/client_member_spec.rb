require 'rails_helper'

feature 'ClientMembers' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let!(:client) { create :client, company: company }

  describe 'showing client_member details' do
    let!(:client_members) { create_list :client_member, 3, client: client, user: create(:user) }

    before do
      login_as user, scope: :user
      visit '/clients'
      expect(page).to have_css('#clients')
    end

    scenario 'shows client_member details', js: true do
      within '#teamsplits tbody' do
        expect(page).to have_css('tr', count: 3)
      end
    end
  end

  describe 'creating a client_member' do
    before do
      login_as user, scope: :user
      visit '/clients'
      expect(page).to have_css('#clients')
    end

    scenario 'pops up a new client modal and creates a new client', js: true do
      find('.new-member').trigger('click')
      expect(page).to have_css('#member_modal')

      within '#member_modal' do
        ui_select('user', user.name)
        fill_in 'share', with: 26
        ui_select('role', 'Owner')

        find_button('Create').trigger('click')
      end

      expect(page).to have_no_css('#member_modal')

      within '#teamsplits tbody' do
        expect(page).to have_css('tr', count: 1)
        expect(find('tr')).to have_text(user.first_name)
        expect(find('tr')).to have_text(user.last_name)
        expect(find('tr')).to have_text('26')
        expect(find('tr')).to have_text('Owner')
      end
    end
  end

  describe 'updating a client_member' do
    let!(:client_member) { create :client_member, client: client, user: create(:user) }
    before do
      login_as user, scope: :user
      visit '/clients'
      expect(page).to have_css('#clients')
    end

    scenario 'update member', js: true do
      within '#teamsplits tbody tr:first-child' do
        share = find('td:nth-child(2) span')
        expect(share).to have_text(client_member.share)
        share.trigger('click')
        expect(page).to have_css('.editable-input', visible: true)
        fill_in 'share', with: '25'
        find('.editable-input').native.send_keys(:Enter)
        expect(share).to have_text '25%'

        role = find('td:nth-child(3) span')
        expect(role).to have_text(client_member.role)
        role.trigger('click')
        expect(page).to have_css('.editable-input', visible: true)
        select 'Can View', from: 'role'
        expect(role).to have_text 'Can View'
      end
    end
  end
end
