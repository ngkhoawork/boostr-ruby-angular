require 'rails_helper'

describe GoogleSpreadsheets::DealSerializer do
  it 'deal serialized data' do
    expect(deal_serializer.opportunity_title).to eq(deal.name)
    expect(deal_serializer.brand).to eq(deal.company.name)
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

  def serialized_for_spreadsheet
    {
      values: [described_class::FIEDLS_ORDER.first(3).map { |field_name| deal_serializer.public_send(field_name) }]
    }
  end
end
