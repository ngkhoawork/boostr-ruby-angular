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

    scenario 'shows client_member details' do
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

    scenario 'pops up a new client modal and creates a new client' do
      find('.new-member').click
      expect(page).to have_css('#member_modal')

      within '#member_modal' do
        ui_select('user', user.name)
        fill_in 'share', with: 26
        ui_select('role', 'Owner')

        click_on 'Create'
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
end
