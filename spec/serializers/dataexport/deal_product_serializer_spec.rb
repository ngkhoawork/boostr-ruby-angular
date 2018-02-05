require 'rails_helper'

describe Dataexport::DealProductSerializer do
  before { serialized_custom_fields }

  it 'serializes deal_product data' do
    expect(serializer.id).to eq(deal_product.id)
    expect(serializer.product_id).to eq(deal_product.product_id)
    expect(serializer.budget_usd).to eq(deal_product.budget)
    expect(serializer.budget).to eq(deal_product.budget_loc)
    expect(serializer.created).to eq(deal_product.created_at)
    expect(serializer.last_updated).to eq(deal_product.updated_at)
    expect(serializer.open).to eq(deal_product.open)
    expect(serializer.custom_fields).to eq(serialized_custom_fields)
  end

  private

  def serializer
    @_serializer ||= described_class.new(deal_product)
  end

  def deal_product
    @_deal_product ||= create :deal_product, product: product, deal: deal
  end

  def product
    @_product ||= create :product, company: company
  end

  def company
    @_company ||= create :company
  end

  def deal
    @_deal ||= create :deal, company: company
  end

  def custom_field
    @_custom_field ||=
      create :deal_product_cf, company: company, deal_product: deal_product, text1: 'Some text'
  end

  def field_name
    @_field_name ||= create :deal_product_cf_name,
                            company: company,
                            field_index: 1,
                            field_type: 'text',
                            field_label: 'Text Field'
  end

  def serialized_custom_fields
    @_serialized_custom_fields ||= {
      field_name.field_label.downcase.gsub(' ', '_') => custom_field.public_send(field_name.field_name)
    }
  end
end
