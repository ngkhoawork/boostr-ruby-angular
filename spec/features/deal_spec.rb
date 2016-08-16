require 'rails_helper'

feature 'Deals' do
  let(:company) { Company.first }
  let(:user) { create :user }
  let!(:advertiser) { create :client, created_by: user.id }
  let!(:agency) { create :client, created_by: user.id }
  let!(:open_stage) { create :stage, position: 1, name: 'open stage' }
  let!(:deal_type_seasonal_option) { create :option, field: deal_type_field(company), name: "Seasonal" }
  let!(:deal_type_pitch_option) { create :option, field: deal_source_field(company), name: "Pitch to Client" }

  describe 'showing a list of deals filtered by stages' do
    let!(:another_open_stage) { create :stage, position: 2 }
    let!(:closed_stage) { create :stage, open: false, position: 3 }
    let!(:open_deal) { create :deal, stage: open_stage, advertiser: advertiser }
    let!(:another_open_deal) { create :deal, stage: another_open_stage, advertiser: advertiser }
    let!(:closed_deal) { create :deal, stage: closed_stage, advertiser: advertiser }

    before do
      set_client_type(advertiser, company, 'Advertiser')
      set_client_type(agency, company, 'Agency')
      open_deal.created_by = user.id
      open_deal.updated_by = user.id
      login_as user, scope: :user
      visit '/deals'
      expect(page).to have_css('#deals')
    end

    scenario 'shows all open deals initially, then filters on stage clicks then deletes a couple', js: true do
      within '.list-group.stages' do
        expect(page).to have_css('.list-group-item', count: 4)
      end

      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 2)
      end

      within '.list-group.stages' do
        find('.list-group-item:nth-child(2)').trigger('click')
      end

      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 1)
        within 'tr' do
          expect(page).to have_text open_deal.name
        end
      end

      within '.list-group.stages' do
        find('.list-group-item:nth-child(3)').trigger('click')
      end

      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 1)
        within 'tr' do
          expect(page).to have_text another_open_deal.name
        end
      end

      within '.list-group.stages' do
        find('.list-group-item:nth-child(4)').trigger('click')
      end

      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 1)
        within 'tr' do
          expect(page).to have_text closed_deal.name
        end
      end

      within '.list-group.stages' do
        find('.list-group-item:nth-child(1)').trigger('click')
      end

      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 2)
        find('tr:first-child').hover
        within 'tr:first-child' do
          find('.delete-deal').trigger('click')
        end
      end

      expect(page).to have_css('.table-wrapper tbody tr', count: 1)

      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 1)
        find('tr:first-child').hover
        within 'tr:first-child' do
          find('.delete-deal').trigger('click')
        end
      end

      expect(page).to have_css('.table-wrapper tbody tr', count: 0)
    end

    scenario 'creates reminder and edits it', js: true do
      within '.table-wrapper' do
        click_link open_deal.name

        within '#deal_overview' do
          expect(page).to have_text(open_deal.name)
          expect(page).to have_css('.clock.show-create-remainders-popup')

          find('.clock.show-create-remainders-popup').trigger('click')
          expect(page).to have_text("Reminder name*")

          within '#reminder_modal' do
            fill_in 'name', with: 'RemindMe!'
            fill_in 'comment', with: 'Deal Reminder'

            find_button('Set Reminder').trigger('click')
          end

          expect(page).not_to have_css('#reminder_modal')

          find('.clock.show-create-remainders-popup').trigger('click')
          expect(page).to have_text("RemindMe!")

          within '#reminder_modal' do
            fill_in 'name', with: 'Reminder update!'
            find_button('Set Reminder').trigger('click')
          end

          expect(page).not_to have_css('#reminder_modal')

          find('.clock.show-create-remainders-popup').trigger('click')
          expect(page).to have_text("Reminder update!")
        end
      end
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

    scenario 'pops up a new deal modal and creates a new deal', js: true do
      find_link('New Deal').trigger('click')

      expect(page).to have_css('#deal_modal')

      within '#deal_modal' do
        fill_in 'name', with: 'Apple Watch Launch'
        ui_select('stage', open_stage.name)
        fill_in 'budget', with: '1234'
        ui_select('advertiser', advertiser.name)
        ui_select('agency', agency.name)
        ui_select('deal-type', 'Seasonal')
        ui_select('source-type', 'Pitch to Client')
        fill_in 'next-steps', with: 'Call Rep'
        fill_in 'start-date', with: '1/1/15'
        fill_in 'end-date', with: '12/31/15'

        find_button('Create').trigger('click')
      end

      expect(page).to have_css('#deal')

      within '#deal_overview h3.deal-name' do
        expect(page).to have_text('Apple Watch Launch')
      end

      within '#info .field-value.deal-type' do
        expect(page).to have_text('Seasonal')
      end
    end
  end
end
