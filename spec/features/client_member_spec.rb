require 'rails_helper'

feature 'ClientMembers' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let!(:client) { create :client, company: company }
  let!(:client_role_manager) { create :option, company: company, field: client_role_field(company), name: "Manager" }

  describe 'showing client_member details' do
    let!(:client_member) { create :client_member, client: client, user: create(:user), values: [create_member_role(company)] }

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
        ui_select('user', user.name)
        fill_in 'share', with: 26
        ui_select('role', 'Owner')

        find_button('Create').trigger('click')
      end

      expect(page).to have_no_css('#member_modal')

      within '#teamsplits tbody' do
        expect(page).to have_css('tr', count: 2, visible: true)
        expect(find('tr:last-child')).to have_text(user.first_name)
        expect(find('tr:last-child')).to have_text(user.last_name)
        expect(find('tr:last-child')).to have_text('26')
        expect(find('tr:last-child')).to have_text('Owner')
      end
    end
  end

  describe 'updating a client_member' do
    let!(:client_member) { create :client_member, client: client, user: create(:user), values: [create_member_role(company)] }
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
        expect(page).to have_css('.editable-input')
        fill_in 'share', with: '25'
        find('.editable-input').native.send_keys(:Enter)
        expect(share).to have_text '25%'

        role_field = find('td:nth-child(3) span')
        expect(role_field).to have_text("Owner")
        # role_field.trigger('click')
        # expect(page).to have_css('form.editable-select')
        # within 'form.editable-select' do
        #   select 'Manager', from: 'role'
        # end
        # expect(role_field).to have_text 'Manager'
      end
    end
  end
end
