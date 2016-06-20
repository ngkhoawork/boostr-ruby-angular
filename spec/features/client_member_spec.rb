require 'rails_helper'

feature 'ClientMembers' do
  let(:company) { Company.first }
  let(:user) { create :user }
  let!(:other_user) { create :user }
  let!(:client) { create :client, created_by: user.id }
  let!(:client_role_manager) { create_member_role(company) }

  describe 'showing client_member details' do
    before do
      login_as user, scope: :user
      visit '/clients'
      expect(page).to have_css('#clients')
    end

    scenario 'shows client_member details', js: true do
      within '#teamsplits tbody' do
        expect(page).to have_css('tr')
      end

      find('.new-member').trigger('click')
      expect(page).to have_css('#member_modal')

      within '#member_modal' do
        ui_select('user', other_user.name)
        fill_in 'share', with: '26'
        ui_select('role', 'Owner')

        find_button('Create').trigger('click')
      end

      expect(page).to have_no_css('#member_modal')

      within '#teamsplits tbody' do
        expect(page).to have_css('tr', count: 2, visible: true)
        expect(page).to have_text(other_user.first_name)
        expect(page).to have_text(other_user.last_name)
        expect(page).to have_text('26')
        expect(page).to have_text('Owner')
      end
    end
  end

  describe 'updating a client_member' do
    before do
      login_as user, scope: :user
      visit '/clients'
      expect(page).to have_css('#clients')
    end

    scenario 'update member', js: true do
      within '#teamsplits tbody tr:first-child' do
        share = find('td:nth-child(2) span')
        expect(share).to have_text(0)
        share.trigger('click')
        expect(page).to have_css('.editable-input')
        fill_in 'share', with: '25'
        find('.editable-input').native.send_keys(:Enter)
        expect(share).to have_text '25%'

        # role_field = find('td:nth-child(3) span')
        # # expect(role_field).to have_text("Owner")
        # role_field.trigger('click')
        # expect(page).to have_css('form.editable-select')
        # within 'form.editable-select' do
        #   select 'Owner', from: 'role'
        # end
        # expect(role_field).to have_text 'Owner'
      end
    end
  end
end
