require 'rails_helper'

feature 'Users' do
  let(:company) { Company.first }
  let(:user) { create :user }
  let!(:pricing_type_cpm) { create :option, field: product_pricing_field(company), name: "CPM" }
  let!(:pricing_type_cpe) { create :option, field: product_pricing_field(company), name: "CPE" }
  let!(:pricing_line_desktop) { create :option, field: product_line_field(company), name: "Desktop" }
  let!(:pricing_line_tablet) { create :option, field: product_line_field(company), name: "Tablet" }
  let!(:pricing_family_banner) { create :option, field: product_family_field(company), name: "Banner" }
  let!(:pricing_video_banner) { create :option, field: product_family_field(company), name: "Video" }

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
        ui_select('family', 'Video')
        ui_select('pricing-type', 'CPE')

        find_button('Update').trigger('click')
      end

      expect(page).to have_no_css('#product-modal')

      within 'table tbody' do
        expect(page).to have_css('tr', count: 1)
        expect(find('tr:first-child td:nth-child(2)')).to have_text('Test')
        expect(find('tr:first-child td:nth-child(3)')).to have_text('Tablet')
        expect(find('tr:first-child td:nth-child(4)')).to have_text('Video')
        expect(find('tr:first-child td:nth-child(5)')).to have_text('CPE')
      end
    end
  end
end
