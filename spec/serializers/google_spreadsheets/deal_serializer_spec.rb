require 'rails_helper'

describe GoogleSpreadsheets::DealSerializer do
  before { create_custom_field }

  it 'deal serialized data' do
    expect(deal_serializer.to_spreadsheet).to eq(serialized_for_spreadsheet)
  end

  private

  def deal_serializer
    @deal_serializer ||= described_class.new(deal)
  end

  def deal
    @_deal ||= create :deal, company: company
  end

  def company
    @_company ||= create :company
  end

  def create_custom_field
    create :deal_custom_field, company: company, deal: deal, dropdown1: 'Some value'

    create :deal_custom_field_name,
           company: company,
           field_index: 1,
           field_type: 'dropdown',
           field_label: 'Creative Ideas Needed'
  end

  def serialized_for_spreadsheet
    {
      values: [described_class::FIEDLS_ORDER.map { |field_name| deal_serializer.public_send(field_name) }]
    }
  end
end
