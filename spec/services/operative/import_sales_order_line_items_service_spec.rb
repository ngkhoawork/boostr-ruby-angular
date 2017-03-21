require 'rails_helper'

RSpec.describe Operative::ImportSalesOrderLineItemsService, datafeed: :true do
  subject(:subject) {
    Operative::ImportSalesOrderLineItemsService.new(
      company.id,
      { sales_order_line_items: line_item_file, invoice_line_item: invoice_file }
    )
  }
  let(:company) { Company.first }
  let(:line_item_file) { './datafeed/sales_order_line_item_file.csv' }
  let(:invoice_file) { './datafeed/invoice_line_item_file.csv' }
  let(:line_item_csv) { double() }

  it 'opens file' do
    expect(File).to receive(:open).with(line_item_file, 'r:ISO-8859-1').and_return(line_item_file)
    expect(File).to receive(:open).with(invoice_file, 'r:ISO-8859-1').and_return(invoice_file)
    subject.perform
  end

  it 'parses CSV file' do
    allow(File).to receive(:open).with(line_item_file, 'r:ISO-8859-1').and_return(line_item_file)
    allow(File).to receive(:open).with(invoice_file, 'r:ISO-8859-1').and_return(invoice_file)
    expect(CSV).to receive(:parse).with(line_item_file, {:headers=>true, :header_converters=>:symbol})
    expect(CSV).to receive(:parse).with(invoice_file, {:headers=>true, :header_converters=>:symbol})
    subject.perform
  end

  it 'passes rows to DisplayLineItemCsv' do
    allow(File).to receive(:open).with(line_item_file, 'r:ISO-8859-1').and_return(line_item_csv_file)
    allow(File).to receive(:open).with(invoice_file, 'r:ISO-8859-1').and_return(invoice_csv_file)
    expect(DisplayLineItemCsv).to receive(:new).with(
      external_io_number: '1',
      line_number: '2',
      ad_server: 'O1',
      start_date: '2017-01-01',
      end_date: '2017-02-01',
      product_name: 'Display',
      quantity: '1000',
      price: '100',
      pricing_type: 'PPC',
      budget: '100000',
      budget_delivered: '1500',
      quantity_delivered: '50',
      quantity_delivered_3p: '60',
      company_id: company.id
    ).and_return(line_item_csv)
    expect(line_item_csv).to receive(:perform)
    subject.perform
  end

  it 'skips a row when line_item_status is not production' do
    allow(File).to receive(:open).with(line_item_file, 'r:ISO-8859-1')
    .and_return(line_item_csv_file(line_item_status: 'deleted'))
    allow(File).to receive(:open).with(invoice_file, 'r:ISO-8859-1')
    .and_return(invoice_csv_file)
    expect(DisplayLineItemCsv).not_to receive(:new)
    subject.perform
  end

  def line_item_csv_file(opts = {})
    @_line_item_csv_file ||= generate_csv({
      sales_order_id: '1',
      sales_order_line_item_id: '2',
      sales_order_line_item_start_date: '2017-01-01',
      sales_order_line_item_end_date: '2017-02-01',
      product_name: 'Display',
      quantity: '1000',
      net_unit_cost: '100',
      cost_type: 'PPC',
      net_cost: '100000',
      line_item_status: 'Sent_to_production'
    }.merge(opts))
  end

  def invoice_csv_file
    @_invoice_csv_file ||= generate_csv({
      sales_order_line_item_id: '2',
      recognized_revenue: '1500',
      cumulative_primary_performance: '50',
      cumulative_third_party_performance: '60'
    })
  end
end
