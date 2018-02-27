require 'rails_helper'

describe Dataexport::DisplayLineItemSerializer do
  it 'serializes display_line_item data' do
    expect(serializer.id).to eq(display_line_item.id)
    expect(serializer.io_id).to eq(display_line_item.io_id)
    expect(serializer.line_number).to eq(display_line_item.line_number)
    expect(serializer.ad_server).to eq(display_line_item.ad_server)
    expect(serializer.quantity).to eq(display_line_item.quantity)
    expect(serializer.budget_usd).to eq(display_line_item.budget)
    expect(serializer.budget).to eq(display_line_item.budget_loc)
    expect(serializer.pricing_type).to eq(display_line_item.pricing_type)
    expect(serializer.product_id).to eq(display_line_item.product_id)
    expect(serializer.budget_delivered_usd).to eq(display_line_item.budget_delivered)
    expect(serializer.budget_remaining_usd).to eq(display_line_item.budget_remaining)
    expect(serializer.quantity_delivered).to eq(display_line_item.quantity_delivered)
    expect(serializer.budget_delivered).to eq(display_line_item.budget_delivered_loc)
    expect(serializer.budget_remaining).to eq(display_line_item.budget_remaining_loc)
    expect(serializer.start_date).to eq(display_line_item.start_date)
    expect(serializer.end_date).to eq(display_line_item.end_date)
    expect(serializer.price).to eq(display_line_item.price)
    expect(serializer.ad_server_product).to eq(display_line_item.ad_server_product)
    expect(serializer.ad_unit).to eq(display_line_item.ad_unit)
    expect(serializer.created).to eq(display_line_item.created_at)
    expect(serializer.last_updated).to eq(display_line_item.updated_at)
  end

  private

  def serializer
    @_serializer ||= described_class.new(display_line_item)
  end

  def display_line_item
    @_display_line_item ||= create :display_line_item,
                                   io: io,
                                   budget: 100.0,
                                   budget_delivered: 50.0,
                                   budget_remaining: 50.0

  end

  def io
    @_io ||= create :io, company: company
  end

  def company
    @_company ||= create :company
  end
end
