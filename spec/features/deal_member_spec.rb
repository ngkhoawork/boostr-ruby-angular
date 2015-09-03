require 'rails_helper'

feature 'DealMembers' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:stage) { create :stage, company: company, position: 1 }
  let(:client) { create :client }
  let!(:deal) { create :deal, stage: stage, company: company, creator: user, end_date: Date.new(2016, 6, 29), advertiser: client }

  describe 'adding a deal_member' do
    before do
      login_as user, scope: :user
      visit "/deals/#{deal.id}"
      expect(page).to have_css('#deal')
    end

    scenario 'add a member from existing users' do
      find('.add-member').click
      find('.existing-user').click
      ui_select('user-list', user.name)

      within '#teamsplits tbody' do
        expect(page).to have_css('tr', count: 1)
        expect(find('tr')).to have_text(user.full_name)
      end
    end
  end
end
