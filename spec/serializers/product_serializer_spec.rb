require 'rails_helper'

describe ProductSerializer do
  it 'product serialized data' do
    expect(product_serializer.name).to eq(product.name)
    expect(product_serializer.active).to eq(product.active)
    expect(product_serializer.is_influencer_product).to eq(product.is_influencer_product)
    expect(product_serializer.product_family_id).to eq(product.product_family_id)
    expect(product_serializer.product_family.symbolize_keys).to eq(id: product.product_family.id,
                                                         name: product.product_family.name)
    expect(product_serializer.revenue_type).to eq(product.revenue_type)
    expect(product_serializer.values).to eq(product.values)
    expect(product_serializer.margin).to eq(product.margin)
  end

  private

  def product_serializer
    @_product_serializer ||= described_class.new(product)
  end

  def product_family
    @_product_family ||= create :product_family, company: company
  end

  def product
    @_product ||= create :product, company: company, product_family: product_family, margin: 38
  end

  def company
    @_company ||= create :company
  end
end
