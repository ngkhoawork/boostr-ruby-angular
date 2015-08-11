require 'rails_helper'

feature 'Individual Deal' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:stage) { create :stage, company: company, position: 1 }
  let(:product) { create :product }
  let!(:other_product) { create :product, company: company  }
  let(:deal) { create :deal, stage: stage, company: company, creator: user, end_date: Date.new(2016,6,29) }

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
          expect(find('td:last-child')).to have_text('$10,000')
        end
      end

      within '#new-product' do
        find('.add-product').click

        expect(page).to have_css '#product-form', visible: true

        within '#product-form' do
          ui_select('product', other_product.name)
          fill_in 'total_budget', with: '240000'

          expect(first('.months .form-control').value).to eq('$20,000')

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
