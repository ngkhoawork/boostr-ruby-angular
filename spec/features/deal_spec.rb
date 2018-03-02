require 'rails_helper'

feature 'Deals' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let!(:advertiser) { create :client, company: company, created_by: user.id, client_type_id: advertiser_type_id(company) }
  let!(:agency) { create :client, company: company, created_by: user.id, client_type_id: agency_type_id(company) }
  let!(:open_stage) { create :stage, company: company, position: 1, name: 'Lead' }
  let!(:deal_type_seasonal_option) { create :option, company: company, field: deal_type_field(company), name: "Seasonal" }
  let!(:deal_type_pitch_option) { create :option, company: company, field: deal_source_field(company), name: "Pitch to Client" }

  describe 'showing a list of deals filtered by stages' do
    let!(:another_open_stage) { create :stage, company: company, position: 2, probability: 50, name: 'Proposal' }
    let!(:closed_stage) { create :stage, company: company, position: 3, probability: 90, name: 'Won' }
    let!(:another_open_deal) do
      create :deal, company: company, stage: another_open_stage,
                    advertiser: advertiser, created_by: user.id, updated_by: user.id
    end
    let!(:closed_deal) do
      create :deal, company: company, stage: closed_stage,
                    advertiser: advertiser, created_by: user.id, updated_by: user.id,
                    closed_at: Date.today
    end
    let!(:closed_deal2) do
      create :deal, company: company, stage: closed_stage,
                    advertiser: advertiser, created_by: user.id, updated_by: user.id,
                    closed_at: Date.today
    end
    let!(:open_deal) do
      create :deal,
        company: company,
        stage: open_stage,
        advertiser: advertiser,
        created_by: user.id,
        updated_by: user.id
    end

    before do
      set_client_type(advertiser, company, 'Advertiser')
      set_client_type(agency, company, 'Agency')

      login_as user, scope: :user
    end

    it 'shows all open deals initially, then filters on stage clicks then deletes a couple', js: true do
      visit '/deals'
      expect(page).to have_css('#deals')

      expect(page).to have_css('.deals-table .deal-column', count: 3)
      expect(page).to have_css('.deals-table .deal-block', count: 4)

      expect(find('.deal-column', text: open_stage.name)).to have_text open_deal.name
      expect(find('.deal-column', text: another_open_stage.name)).to have_text another_open_deal.name
      expect(find('.deal-column', text: closed_stage.name)).to have_text closed_deal.name

      within('.deal-column', text: open_stage.name) do
        find('.block-menu').click
        click_on 'Delete'

        expect(page).to_not have_text open_deal.name
      end

      wait_for_ajax

      expect(page).to have_css('.deals-table .deal-block', count: 3)
    end
  end

  describe 'creating a deal' do
    before do
      set_client_type(advertiser, company, 'Advertiser')
      set_client_type(agency, company, 'Agency')
      login_as user, scope: :user
      visit '/deals'
      expect(page).to have_css('#deals')
    end

    it 'pops up a new deal modal and creates a new deal', js: true do
      click_button 'Add Deal'

      expect(page).to have_css('#deal_modal')

      within '#deal_modal' do
        fill_in 'name', with: 'Apple Watch Launch'
        ui_select('stage', open_stage.name)
        find('[name=start-date]').click
        find('ul td button', match: :first).click
        find('[name=end-date]').click
        find('ul td button', match: :first).click
        find('[name=advertiser]').click
        find("input[placeholder='Advertiser']").set advertiser.name
        find('ul li').click

        find_button('Create').trigger('click')
        wait_for_ajax
      end

      expect(page).to have_no_css('#deal_modal')
      expect(page).to have_text('Apple Watch Launch')

    end
  end
end
