require 'rails_helper'

feature 'Users' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  describe 'creating a new product' do
    before do
      login_as user, scope: :user
      visit '/settings/products'
      expect(page).to have_css('#products')
    end

    scenario 'creating a product' do
      find('.add-product').click

      expect(page).to have_css('#product-modal')

      within '#product-modal' do
        fill_in 'name', with: 'Banner'
        ui_select('product-line', 'Desktop')
        ui_select('family', 'Banner')
        ui_select('pricing-type', 'CPM')

        click_on 'Create'
      end

      expect(page).to have_no_css('#product-modal')

      within '.table-wrapper tbody' do
        expect(page).to have_css('tr', count: 1)
      end
    end
  end
  describe 'update a product' do
    let!(:products) { create_list :product, 3, company: company }

    before do
      login_as user, scope: :user
      visit '/settings/products'
      expect(page).to have_css('#products')
    end

    scenario 'pops up an edit product modal and updates a product' do
      within 'table tbody' do
        find('tr:first-child').click
      end

      expect(page).to have_css('#product-modal')

      within '#product-modal' do
        fill_in 'name', with: 'Test'
        ui_select('product-line', 'Tablet')
        ui_select('family', 'Banner')
        ui_select('pricing-type', 'CPE')

        click_on 'Update'
      end

      expect(page).to have_no_css('#product-modal')

      within 'table tbody' do
        expect(find('tr:first-child td:nth-child(2)')).to have_text('Test')
        expect(find('tr:first-child td:nth-child(3)')).to have_text('Tablet')
        expect(find('tr:first-child td:nth-child(4)')).to have_text('Banner')
        expect(find('tr:first-child td:nth-child(5)')).to have_text('CPE')
      end
    end
  end
end
