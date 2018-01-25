require 'rails_helper'

describe Dataexport::AccountSerializer do
  before { serialized_custom_fields }

  it 'serializes account data' do
    expect(serializer.id).to eq(account.id)
    expect(serializer.name).to eq(account.name)
    expect(serializer.type).to eq(account.client_type.name)
    expect(serializer.category).to eq(account.client_category.name)
    expect(serializer.sub_category).to eq(account.client_subcategory.name)
    expect(serializer.parent_account).to eq(account.parent_client.name)
    expect(serializer.region).to eq(account.client_region.name)
    expect(serializer.segment).to eq(account.client_segment.name)
    expect(serializer.holding_company).to eq(account.holding_company.name)
    expect(serializer.created).to eq(account.created_at)
    expect(serializer.last_updated).to eq(account.updated_at)
    expect(serializer.custom_fields).to eq(serialized_custom_fields)
  end

  private

  def serializer
    @_serializer ||= described_class.new(account)
  end

  def account
    @_account ||= create :client,
                         :advertiser,
                         company: company,
                         client_category: client_category,
                         client_subcategory: client_subcategory,
                         client_region: client_region,
                         client_segment: client_segment,
                         holding_company: holding_company
  end

  def company
    @_company ||= create :company
  end

  def client_category
    @_client_category ||= create :option, field: category_field
  end

  def category_field
    @_category_field ||= create :field, name: "Category"
  end

  def client_subcategory
    @_client_subcategory ||= create :option, field: subcategory_field
  end

  def subcategory_field
    @_subcategory_field ||= create :field, name: "Subcategory"
  end

  def client_region
    @_client_region ||= create :option, field: region_field
  end

  def region_field
    @_region_field ||= create :field, name: "Region"
  end

  def client_segment
    @_client_segment ||= create :option, field: segment_field
  end

  def segment_field
    @_segment_field ||= create :field, name: "Segment"
  end

  def holding_company
    @_holding_company ||= create :holding_company
  end

  def custom_field
    @_custom_field ||= create :account_cf, company: company, client: account, text1: 'Some text'
  end

  def field_name
    @_field_name ||= create :account_cf_name,
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
