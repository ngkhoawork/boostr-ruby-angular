require 'rails_helper'

feature 'ClientMembers' do
  let(:company) { create :company }
  let(:user) { create :user }
  let!(:other_user) { create :user }
  let!(:client) { create :client, created_by: user.id }
  let!(:client_role_manager) { create_member_role(company) }

  describe 'adding client_members' do
    before do
      login_as user, scope: :user
      visit "/accounts/#{client.id}"
    end

    xit 'adding client_member details', js: true do
      within :css, 'div.members.block' do
        find('add-button.dropdown-toggle').click
      end
      expect(page).to have_css('ul.dropdown-menu.new-member-options')

      find('ul.dropdown-menu.new-member-options').click
      find('#ui-select-choices-row-0-0').click

      expect(page).to have_no_css('ul.dropdown-menu.new-member-options')
      within :css, 'div.members.block' do
        expect(page).to have_css('tbody > tr', count: 2, visible: true)
        expect(page).to have_text(other_user.name)
      end
    end
  end

  describe 'updating a client_member' do
    before do
      login_as user, scope: :user
      visit "/accounts/#{client.id}"
    end

    xit 'update member', js: true do
      within 'div.members.block tbody tr:first-child' do
        share = find('td:nth-child(3) div.editable')
        role = find('td:nth-child(2) button.dropdown-toggle')
        expect(share).to have_text(0)
        share.click
        expect(page).to have_css('input.editable-field')
        fill_in 'inputText', with: '25'

        role.click
        role.click

        find('ul.dropdown-menu li', :text => 'Owner').click

        expect(share).to have_text '25%'
        expect(role).to have_text 'Owner'
      end
    end
  end
end
