require 'rails_helper'

feature 'Deals' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let!(:advertiser) { create :client, company: company, client_type: 'Advertiser' }
  let!(:agency) { create :client, company: company, client_type: 'Agency' }
  let!(:open_stage) { create :stage, company: company, position: 1 }

  describe 'showing a list of deals filtered by stages' do
    let!(:another_open_stage) { create :stage, company: company, position: 2 }
    let!(:closed_stage) { create :stage, company: company, open: false, position: 3 }
    let!(:open_deal) { create :deal, stage: open_stage, company: company, advertiser: advertiser }
    let!(:another_open_deal) { create :deal, stage: another_open_stage, company: company, advertiser: advertiser }
    let!(:closed_deal) { create :deal, stage: closed_stage, company: company, advertiser: advertiser }

    before do
      login_as user, scope: :user
      visit '/deals'
      expect(page).to have_css('#deals')
    end

    scenario 'shows all open deals initially, then filters on stage clicks' do
      within '.list-group.stages' do
        expect(page).to have_css('.list-group-item', count: 4)
      end

      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 2)
      end

      within '.list-group.stages' do
        find('.list-group-item:nth-child(2)').click
      end

      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 1)
        within 'tr' do
          expect(page).to have_text open_deal.name
        end
      end

      within '.list-group.stages' do
        find('.list-group-item:nth-child(3)').click
      end

      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 1)
        within 'tr' do
          expect(page).to have_text another_open_deal.name
        end
      end

      within '.list-group.stages' do
        find('.list-group-item:nth-child(4)').click
      end

      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 1)
        within 'tr' do
          expect(page).to have_text closed_deal.name
        end
      end

      within '.list-group.stages' do
        find('.list-group-item:first-child').click
      end

      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 2)
      end
    end
  end

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
        ui_select('stage', open_stage.name)
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