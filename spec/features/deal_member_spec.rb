require 'rails_helper'

feature 'DealMembers' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:stage) { create :stage, company: company, position: 1 }
  let(:client) { create :client }
  let!(:deal) { create :deal, stage: stage, company: company, creator: user, end_date: Date.new(2016, 6, 29), advertiser: client }
  let!(:deal_type_seasonal_option) { create :option, company: company, field: deal_type_field(company), name: "Seasonal" }
  let!(:deal_type_value) { create :value, company: company, field: deal_type_field(company), subject: deal, option: deal_type_seasonal_option }
  let!(:client_member_role_option) { create :option, company: company, field: client_role_field(company), name: "Member" }

  describe 'adding a deal_member' do
    before do
      login_as user, scope: :user
      visit "/deals/#{deal.id}"
      expect(page).to have_css('#deal')
    end

    scenario 'add a member from existing users', js: true do
      find('.add-member').trigger('click')
      find('.existing-user-options').trigger('click')
      ui_select('user-list', user.name)

      within '#teamsplits tbody' do
        expect(page).to have_css('tr', count: 1)
        expect(find('tr')).to have_text(user.name)
      end
    end
  end

  describe 'updating a deal_member' do
    let!(:deal_member) { create :deal_member, deal_id: deal.id, user_id: user.id, values:[create_member_role(company)] }

    before do
      login_as user, scope: :user
      visit "/deals/#{deal.id}"
      expect(page).to have_css('#deal')
    end

    scenario 'update member', js: true do
      within '#teamsplits tbody tr:first-child' do
        role = find('td:nth-child(2) span')
        expect(role).to have_text('Owner')
        role.trigger('click')
        expect(page).to have_css('.editable-input', visible: true)
        select 'Member', from: 'role'
        expect(role).to have_text 'Member'

        share = find('td:nth-child(3) span')
        expect(share).to have_text(deal_member.share)
        share.trigger('click')
        expect(page).to have_css('.editable-input', visible: true)
        fill_in 'share', with: '25'
        find('.editable-input').native.send_keys(:Enter)
        expect(share).to have_text '25%'
      end
    end
  end

  describe 'deleting a deal_member' do
    let!(:deal_member) { create_list :deal_member, 3, deal_id: deal.id }
    before do
      login_as user, scope: :user
      visit "/deals/#{deal.id}"
      expect(page).to have_css('#deal')
    end

    scenario 'delete member', js: true do
      within '#teamsplits tbody' do
        expect(page).to have_css('tr', count: 3)
        find('tr:first-child').hover
        within 'tr:first-child' do
          find('.delete-member').trigger('click')
        end
        expect(page).to have_css('tr', count: 2)
      end
    end
  end
end
