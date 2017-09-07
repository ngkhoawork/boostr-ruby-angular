require 'rails_helper'

feature 'Users' do
  let(:company) { Company.first }
  let(:user) { create :user, company: company }

  before do
    login_as user, scope: :user
  end

  describe 'creating a new product' do
    before do
      visit '/settings/products'
      expect(page).to have_css('#products')
    end

    xit 'creating a product', js: true do
      find('add-button', text: 'Add').trigger('click')

      expect(page).to have_css('#product-modal')

      within '#product-modal' do
        fill_in 'name', with: 'Banner'
        find('div[name=revenue-type]').click

        wait_for_ajax 1

        find('ul a', text: 'Display').click

        find_button('Create').trigger('click')
      end

      wait_for_ajax

      expect(page).to have_no_css('#product-modal')
      expect(page).to have_text('Display')
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

        find_button('Update').trigger('click')
      end

      wait_for_ajax

      expect(page).to have_no_css('#product-modal')
      expect(page).to have_text('Banner')
    end
  end
end
