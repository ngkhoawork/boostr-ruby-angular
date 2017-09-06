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

  before do
    login_as user, scope: :user
  end

  describe 'creating a new product' do
    before do
      visit '/settings/products'
      expect(page).to have_css('#products')
    end

    it 'creating a product', js: true do
      find('add-button', text: 'Add').trigger('click')

      expect(page).to have_css('#product-modal')

      within '#product-modal' do
        fill_in 'name', with: 'Banner'
        ui_select('product-line', 'Desktop')
        ui_select('family', 'Banner')
        ui_select('pricing-type', 'CPM')
        find('div[name=revenue-type]').click
        find('ul li', match: :first).click

        find_button('Create').trigger('click')
      end

      expect(page).to have_no_css('#product-modal')
      expect(page).to have_text('Banner')
      expect(page).to have_text('Desktop')
      expect(page).to have_text('CPM')
      expect(page).to have_text('Content-Fee')
    end
  end

  describe 'update a new product' do
    let!(:product) { create :product, company: company }

    before do
      visit '/settings/products'
      expect(page).to have_css('#products')
    end

    it 'updating a product', js: true do
      find('tbody i.fa-pencil', visible: false).trigger('click')

      within '#product-modal' do
        fill_in 'name', with: 'Banner'
        ui_select('product-line', 'Desktop')
        ui_select('family', 'Banner')
        ui_select('pricing-type', 'CPM')

        find_button('Update').trigger('click')
      end

      expect(page).to have_no_css('#product-modal')
      expect(page).to have_text('Banner')
      expect(page).to have_text('Desktop')
      expect(page).to have_text('CPM')
    end
  end
end
