require 'rails_helper'

feature 'Users' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  describe 'creating a new product' do

    before do
      login_as user, scope: :user
      visit "/settings/products"
      expect(page).to have_css('#products')
    end

    scenario 'pops up a modal and sends the user an email' do
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
end