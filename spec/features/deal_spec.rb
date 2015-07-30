require 'rails_helper'

feature 'Deals' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let!(:advertiser) { create :client, company: company, client_type: 'Advertiser' }
  let!(:agency) { create :client, company: company, client_type: 'Agency' }

  describe 'creating a deal' do
    before do
      login_as user, scope: :user
      visit '/deals'
      expect(page).to have_css('#deals')
    end

    scenario 'pops up a new contact modal and creates a new contact' do
      click_link('New Deal')

      expect(page).to have_css('#deal_modal')

      within '#deal_modal' do
        fill_in 'name', with: 'Apple Watch Launch'
        ui_select('stage', 'Prospect')
        fill_in 'budget', with: '1234'
        ui_select('advertiser', advertiser.name)
        ui_select('agency', agency.name)

        click_on 'Create'
      end

      expect(page).to have_no_css('#deal_modal')

      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 1)
        expect(find('tr:first-child')).to have_text('Apple Watch Launch')
      end
    end
  end
end