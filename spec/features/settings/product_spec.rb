require 'rails_helper'

feature 'Users' do
  before do
    login_as user, scope: :user
  end

  describe 'creating a new product' do
    before do
      visit '/settings/products'
      expect(page).to have_css('#products')
    end

    it 'creating a product', js: true do
      find('add-button.add-product', text: 'Add').trigger('click')

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
    before do
      product
      visit '/settings/products'
      expect(page).to have_css('#products')
    end

    it 'updating a product', js: true do
      find('tbody i.fa-pencil.edit-product', visible: false).trigger('click')

      within '#product-modal' do
        fill_in 'name', with: 'Banner'

        find_button('Update').trigger('click')
      end

      wait_for_ajax

      expect(page).to have_no_css('#product-modal')
      expect(page).to have_text('Banner')
    end
  end

  describe 'creating a new product family' do
    before do
      visit '/settings/products'
      expect(page).to have_css('#product-families')
    end

    it 'creating a product family', js: true do
      find('add-button.add-family', text: 'Add').trigger('click')

      expect(page).to have_css('#product-family-modal')

      within '#product-family-modal' do
        fill_in 'name', with: 'Banner'

        find_button('Create').trigger('click')
      end

      wait_for_ajax

      expect(page).to have_no_css('#product-modal')
      expect(page).to have_text('Banner')
    end
  end

  describe 'update a new product family' do
    before do
      product_family
      visit '/settings/products'
      expect(page).to have_css('#product-families')
    end

    it 'updating a product family', js: true do
      find('tbody i.fa-pencil.edit-family', visible: false).trigger('click')

      expect(page).to have_css('#product-family-modal')

      within '#product-family-modal' do
        fill_in 'name', with: 'Banner'

        find_button('Update').trigger('click')
      end

      wait_for_ajax

      expect(page).to have_no_css('#product-family-modal')
      expect(page).to have_text('Banner')
    end
  end
  private

  def user
    @_user ||= create :user, company: company
  end

  def product_family
    @_product_family ||= create :product_family, company: company
  end

  def product
    @_product ||= create :product, company: company, product_family: product_family
  end

  def company
    @_company ||= create :company
  end
end
