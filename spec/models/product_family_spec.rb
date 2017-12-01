require 'rails_helper'

RSpec.describe ProductFamily, 'model' do
  describe '#destroy' do
    before do
      products
    end
    it 'remove relations from related products' do
      product_family.destroy
      products.each do |product|
        expect(product.reload.product_family_id).to be_nil
      end
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def product_family
    @_product_family ||= create :product_family, company: company
  end

  def products
    @_products ||= create_list :product, 3, product_family: product_family, company: company
  end
end

RSpec.describe ProductFamily, 'validation' do
  it { should validate_presence_of(:name) }
end

RSpec.describe ProductFamily, 'association' do
  it { should belong_to(:company) }
  it { should have_many(:products) }
end