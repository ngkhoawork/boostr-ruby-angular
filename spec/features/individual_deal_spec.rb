require 'rails_helper'

feature 'Individual Deal' do
  let(:company) { Company.first }
  let(:client) { create :client }
  let!(:client_role_owner) { create :option, field: client_role_field(company), name: "Owner" }
  let(:role) { create :value, field: client_role_field(company), option: client_role_owner }
  let(:user) { create :user }
  let!(:client_member) { create :client_member, user: user, client: client, values: [role] }
  let(:stage) { create :stage, position: 1 }
  let(:product) { create :product }
  let!(:other_product) { create :product  }
  let!(:second_product) { create :product  }
  let(:deal) { create :deal, stage: stage, creator: user, end_date: Date.new(2016, 6, 29), advertiser: client }
  let!(:deal_source_pitch_option) { create :option, field: deal_source_field(company), name: "Pitch to Client" }
  let!(:deal_source_rfp_option) { create :option, field: deal_source_field(company), name: "RFP Response to Client" }
  let!(:deal_source_value) { create :value, field: deal_source_field(company), subject: deal, option: deal_source_pitch_option }
  let!(:deal_type_seasonal_option) { create :option, field: deal_type_field(company), name: "Seasonal" }
  let!(:deal_type_renewal_option) { create :option, field: deal_type_field(company), name: "Renewal" }
  let!(:deal_type_value) { create :value, field: deal_type_field(company), subject: deal, option: deal_type_seasonal_option }

  describe 'showing deal details' do
    before do
      login_as user, scope: :user
      deal.add_product(product.id, '120000')
      visit "/deals/#{deal.id}"
      expect(page).to have_css('#deal')
    end

    scenario 'shows deal details and stage', js: true do
      within '#nav.transparent.sec' do
        first('li a').trigger('click')
      end

      first_deal_product = deal.deal_products.where(product_id: product.id).first
      within '#deal_overview' do
        deal_name = find('h3.deal-name')
        expect(deal_name).to have_text(deal.name)
        deal_name.trigger('click')
        expect(page).to have_css('.editable-input', visible: true)
        fill_in 'deal-name', with: 'Taco'
        find('.editable-input').native.send_keys(:Enter)
        expect(deal_name).to have_text 'Taco'
      end

      within '#nav.transparent.sec' do
        find('li:nth-child(4) a').trigger('click')
      end

      within '#info' do
        expect(find('h3.header')).to have_text('Additional Info')

        deal_type = find('.field:first-child .field-value')
        expect(deal_type).to have_text(deal_type_seasonal_option.name)
        deal_type.trigger('click')
        expect(page).to have_css('.editable-input', visible: true)
        select 'Renewal', from: 'deal-type'
        expect(page).to have_no_css('.editable-input')
        expect(deal_type).to have_text 'Renewal'

        deal_source = find('.field:nth-child(2) .field-value')
        expect(deal_source).to have_text(deal_source_pitch_option.name)
        deal_source.trigger('click')
        expect(page).to have_css('.editable-input', visible: true)
        select 'RFP Response to Client', from: 'deal-source'
        expect(page).to have_no_css('.editable-input')
        expect(deal_source).to have_text 'RFP Response to Client'

        next_steps = find('.field:nth-child(3) .field-value')
        expect(next_steps).to have_text(deal.next_steps)
        next_steps.trigger('click')
        expect(page).to have_css('.editable-input', visible: true)
        fill_in 'next-steps', with: 'Testing'
        find('.editable-input').native.send_keys(:Enter)
        expect(next_steps).to have_text 'Testing'
      end

      expect(find('#total-amount')).to have_text('$120,000')
      expect(find('#forecast')).to have_text('$12,000')
      expect(find('.stage')).to have_text('PROSPECT 10% PROBABILITY')

      within '#revenue_schedule' do
        within 'thead' do
          expect(page).to have_css('th', count: 14)
          expect(find('th:last-child')).to have_text('Jun 2016')
        end

        within 'tbody' do
          expect(page).to have_css('tr', count: 1)
          expect(find('td:nth-child(2)')).to have_text('$120,000') # jul
          expect(find('td:nth-child(3)')).to have_text('$1,068') # jul
          expect(find('td:nth-child(4)')).to have_text('$11,038') # aug
          expect(find('td:nth-child(5)')).to have_text('$10,682') # sep
          expect(find('td:nth-child(6)')).to have_text('$11,038') # oct
          expect(find('td:nth-child(7)')).to have_text('$10,682') # nov
          expect(find('td:nth-child(8)')).to have_text('$11,038') # dec
          expect(find('td:nth-child(9)')).to have_text('$11,038') # jan
          expect(find('td:nth-child(10)')).to have_text('$10,326') # feb(leap year)
          expect(find('td:nth-child(11)')).to have_text('$11,038') # mar
          expect(find('td:nth-child(12)')).to have_text('$10,682') # apr
          expect(find('td:nth-child(13)')).to have_text('$11,038') # may
          expect(find('td:nth-child(14)')).to have_text('$10,326') # jun

          find('td:nth-child(3) span').trigger('click')
          fill_in "#{first_deal_product.id}", with: '1000'
          find('td:nth-child(3) input').native.send_keys(:Enter)
        end
      end

      expect(find('#total-amount')).to have_text('$119,932')

      within '#new-product' do
        find('.add-product').trigger('click')

        expect(page).to have_css '#product-form', visible: true

        within '#product-form' do
          ui_select('product', other_product.name)
          fill_in 'total_budget', with: '240000'

          month_fields = all('.months .form-control')
          expect(month_fields[0].value).to eq('$2,136') # jul
          expect(month_fields[1].value).to eq('$22,077') # aug
          expect(month_fields[2].value).to eq('$21,365') # sep
          expect(month_fields[3].value).to eq('$22,077') # oct
          expect(month_fields[4].value).to eq('$21,365') # nov
          expect(month_fields[5].value).to eq('$22,077') # dec
          expect(month_fields[6].value).to eq('$22,077') # jan
          expect(month_fields[7].value).to eq('$20,653') # feb (leap year)
          expect(month_fields[8].value).to eq('$22,077') # mar
          expect(month_fields[9].value).to eq('$21,365') # apr
          expect(month_fields[10].value).to eq('$22,077') # may
          expect(month_fields[11].value).to eq('$20,653') # jun

          find_button('Add Product').trigger('click')
        end

        find('.add-product').trigger('click')

        expect(page).to have_css '#product-form', visible: true

        within '#product-form' do
          ui_select('product', second_product.name)
          fill_in 'total_budget', with: '240000'

          month_fields = all('.months .form-control')
          expect(month_fields[0].value).to eq('$2,136') # jul
          expect(month_fields[1].value).to eq('$22,077') # aug
          expect(month_fields[2].value).to eq('$21,365') # sep
          expect(month_fields[3].value).to eq('$22,077') # oct
          expect(month_fields[4].value).to eq('$21,365') # nov
          expect(month_fields[5].value).to eq('$22,077') # dec
          expect(month_fields[6].value).to eq('$22,077') # jan
          expect(month_fields[7].value).to eq('$20,653') # feb (leap year)
          expect(month_fields[8].value).to eq('$22,077') # mar
          expect(month_fields[9].value).to eq('$21,365') # apr
          expect(month_fields[10].value).to eq('$22,077') # may
          expect(month_fields[11].value).to eq('$20,653') # jun

          find_button('Cancel').trigger('click')
        end

        expect(page).to have_no_css '#product-form'
      end

      within '#revenue_schedule' do
        within 'tbody' do
          expect(page).to have_css('tr', count: 2)
        end
      end

      expect(find('#total-amount')).to have_text('$359,932')

      within '.black-table.sec tbody' do
        expect(page).to have_css('tr', count: 1)
      end
    end
  end
end
