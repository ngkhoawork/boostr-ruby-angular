require 'rails_helper'

describe Dataexport::ProductSerializer do
  it 'serializes product data' do
    expect(serializer.id).to eq(product.id)
    expect(serializer.name).to eq(product.name)
    expect(serializer.product_family).to eq(product.product_family.name)
    expect(serializer.revenue_type).to eq(product.revenue_type)
    expect(serializer.active).to eq(product.active)
    expect(serializer.created).to eq(product.created_at)
    expect(serializer.last_updated).to eq(product.updated_at)
  end

  private

  def serializer
    @_serializer ||= described_class.new(product)
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
