require 'rails_helper'

feature 'Individual Deal' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:stage) { create :stage, company: company, position: 1 }
  let(:product) { create :product }
  let!(:other_product) { create :product, company: company  }
  let(:deal) { create :deal, stage: stage, company: company, creator: user, end_date: Date.new(2016, 6, 29) }

  describe 'showing deal details' do
    before do
      login_as user, scope: :user
      deal.add_product(product, '120000')
      visit "/deals/#{deal.id}"
      expect(page).to have_css('#deal')
    end

    scenario 'shows deal details and stage' do
      within '#deal_overview' do
        expect(find('h3.deal-name')).to have_text(deal.name)

        within '#stage_overview' do
          expect(page).to have_css('.details')
          expect(find('.details .type')).to have_text(stage.name)
        end
      end

      within '#add_info' do
        expect(find('h3.header')).to have_text('Additional Info')
      end

      within '#revenue_schedule' do
        within 'thead' do
          expect(page).to have_css('th', count: 13)
          expect(find('th:last-child')).to have_text('Jun 2016')
        end

        within 'tbody' do
          expect(page).to have_css('tr', count: 1)
          expect(find('td:nth-child(2)')).to have_text('$714') #jul
          expect(find('td:nth-child(3)')).to have_text('$11,071') #aug
          expect(find('td:nth-child(4)')).to have_text('$10,714') #sep
          expect(find('td:nth-child(5)')).to have_text('$11,071') #oct
          expect(find('td:nth-child(6)')).to have_text('$10,714') #nov
          expect(find('td:nth-child(7)')).to have_text('$11,071') #dec
          expect(find('td:nth-child(8)')).to have_text('$11,071') #jan
          expect(find('td:nth-child(9)')).to have_text('$10,357') #feb(leap year)
          expect(find('td:nth-child(10)')).to have_text('$11,071') #mar
          expect(find('td:nth-child(11)')).to have_text('$10,714') #apr
          expect(find('td:nth-child(12)')).to have_text('$11,071') #may
          expect(find('td:nth-child(13)')).to have_text('$10,357') #jun
        end
      end

      within '#new-product' do
        find('.add-product').click

        expect(page).to have_css '#product-form', visible: true

        within '#product-form' do
          ui_select('product', other_product.name)
          fill_in 'total_budget', with: '240000'

          month_fields = all('.months .form-control')
          expect(month_fields[0].value).to eq('$1,429') #jul
          expect(month_fields[1].value).to eq('$22,143') #aug
          expect(month_fields[2].value).to eq('$21,429') #sep
          expect(month_fields[3].value).to eq('$22,143') #oct
          expect(month_fields[4].value).to eq('$21,429') #nov
          expect(month_fields[5].value).to eq('$22,143') #dec
          expect(month_fields[6].value).to eq('$22,143') #jan
          expect(month_fields[7].value).to eq('$20,714') #feb (leap year)
          expect(month_fields[8].value).to eq('$22,143') #mar
          expect(month_fields[9].value).to eq('$21,429') #apr
          expect(month_fields[10].value).to eq('$22,143') #may
          expect(month_fields[11].value).to eq('$20,714') #jun

          click_on 'Add Product'
        end
      end

      within '#revenue_schedule' do
        within 'tbody' do
          expect(page).to have_css('tr', count: 2)
        end
      end
    end
  end
end
