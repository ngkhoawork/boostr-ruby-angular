require 'rails_helper'

feature 'DealMembers' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let!(:second_user) { create :user, company: company }
  let(:stage) { create :stage, position: 1 }
  let(:client) { create :client }
  let!(:deal) { create :deal, stage: stage, creator: user, end_date: Date.new(2016, 6, 29), advertiser: client }
  let!(:deal_type_seasonal_option) { create :option, field: deal_type_field(company), name: "Seasonal" }
  let!(:deal_type_value) { create :value, field: deal_type_field(company), subject: deal, option: deal_type_seasonal_option }
  let!(:client_member_role_option) { create :option, field: client_role_field(company), name: "Member" }

  describe 'adding a deal_member' do
    before do
      login_as user, scope: :user
      visit "/deals/#{deal.id}"
      expect(page).to have_css('#deal')
    end

    it 'add a member from existing users', js: true do
      find('.members add-button', text: 'Add').trigger('click')
      find('.existing-user-options').click
      find('a', text: second_user.name).click

      within '.members tbody' do
        expect(page).to have_css('tr', count: 2)
        expect(page).to have_text(user.name)
      end
    end
  end

  describe 'updating a deal_member' do
    let!(:deal_member) do
      create :deal_member, share: 0, deal_id: deal.id, user_id: second_user.id, values:[create_member_role(company)]
    end

    before do
      login_as user, scope: :user
      visit "/deals/#{deal.id}"
      expect(page).to have_css('#deal')
    end

    xit 'update member', js: true do
      within '.members' do
        role = find('tr', text: second_user.name).find('td:nth-child(2)').text
        expect(role).to have_text('Owner')

        find('div.dropdown', text: role).click
        click_on 'Member'

        wait_for_ajax 0.5

        role = find('tr', text: second_user.name).find('td:nth-child(2)').text
        expect(role).to have_text 'Member'

        share = find('tr', text: user.name).find('td:nth-child(3)').text
        expect(share).to have_text('100%')

        find('tr', text: user.name).find('input.editable-field', match: :first, visible: false).set(25)

        wait_for_ajax 0.5

        share = find('tr', text: user.name).find('td:nth-child(3)').text
        expect(share).to have_text '25%'
      end
    end
  end

  describe 'deleting a deal_member' do
    let!(:deal_member) { create_list :deal_member, 3, deal_id: deal.id }

    before do
      window_size_for_screenshot 2000, 1400
      login_as user, scope: :user
      visit "/deals/#{deal.id}"
      expect(page).to have_css('#deal')
    end

    it 'delete member', js: true do
      within '.members tbody' do
        expect(page).to have_css('tr', count: 4)

        find('tr', text: user.name).find('.delete-deal', visible: false).trigger('click')

        expect(page).to have_css('tr', count: 3)
      end
    end
  end
end
