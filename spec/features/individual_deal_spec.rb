require 'rails_helper'

feature 'Individual Deal' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let!(:advertiser) { create :client, company: company, client_type: 'Advertiser' }
  let!(:agency) { create :client, company: company, client_type: 'Agency' }
  let!(:open_stage) { create :stage, company: company, position: 1 }
  let!(:open_deal) { create :deal, stage: open_stage, company: company, advertiser: advertiser }

  describe 'showing deal details' do
    before do
      login_as user, scope: :user
      visit "/deals/#{open_deal.id}"
      expect(page).to have_css('#deal')
    end

    scenario 'shows deal details and stage' do
      within '#deal_overview' do
        expect(find('h3.deal-name')).to have_text(open_deal.name)

        within '#stage_overview' do
          expect(page).to have_css('.details')
          expect(find('.details .type')).to have_text(open_deal.stage.name)
        end
      end
    end

    scenario 'shows additional info' do
      within '#add_info' do
        expect(find('h3.header')).to have_text('Additional Info')
      end
    end
  end
end
