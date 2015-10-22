require 'rails_helper'

feature 'Users' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let!(:pricing_type_cpm) { create :option, company: company, field: product_pricing_field(company), name: "CPM" }
  let!(:pricing_type_cpe) { create :option, company: company, field: product_pricing_field(company), name: "CPE" }

  describe 'creating a new product' do
    before do
      login_as user, scope: :user
      visit '/settings/products'
      expect(page).to have_css('#products')
    end

    scenario 'creating a product', js: true do
      find('.add-product').trigger('click')

      expect(page).to have_css('#product-modal')

      within '#product-modal' do
        fill_in 'name', with: 'Banner'
        ui_select('product-line', 'Desktop')
        ui_select('family', 'Banner')
        ui_select('pricing-type', 'CPM')

        find_button('Create').trigger('click')
      end

      expect(page).to have_no_css('#product-modal')

      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 1)
      end

      within 'table tbody' do
        expect(page).to have_css('tr', count: 1)
        find('tr:first-child').trigger('click')
      end

      expect(page).to have_css('#product-modal')

      within '#product-modal' do
        fill_in 'name', with: 'Test'
        ui_select('product-line', 'Tablet')
        ui_select('family', 'Banner')
        ui_select('pricing-type', 'CPE')

        find_button('Update').trigger('click')
      end

      expect(page).to have_no_css('#product-modal')

      within 'table tbody' do
        expect(page).to have_css('tr', count: 1)
        expect(find('tr:first-child td:nth-child(2)')).to have_text('Test')
        expect(find('tr:first-child td:nth-child(3)')).to have_text('Tablet')
        expect(find('tr:first-child td:nth-child(4)')).to have_text('Banner')
        expect(find('tr:first-child td:nth-child(5)')).to have_text('CPE')
      end
    end
  end
end
