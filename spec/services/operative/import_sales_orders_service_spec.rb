require 'rails_helper'

RSpec.describe Operative::ImportSalesOrdersService, datafeed: :true do
  subject(:subject) {
    Operative::ImportSalesOrdersService.new(
      company.id,
      {sales_order: sales_order_file, currency: currency_file}
    )
  }
  let(:company) { Company.first }
  let(:sales_order_file) { './datafeed/sales_order_file.csv' }
  let(:currency_file) { './datafeed/currency_file.csv' }
  let(:io_csv) { double() }

  it 'opens file' do
    expect(File).to receive(:open).with(sales_order_file, 'r:ISO-8859-1').and_return(sales_order_file)
    expect(File).to receive(:open).with(currency_file, 'r:ISO-8859-1').and_return(currency_csv)
    subject.perform
  end

  it 'parses CSV file' do
    allow(File).to receive(:open).with(sales_order_file, 'r:ISO-8859-1').and_return(sales_order_file)
    allow(File).to receive(:open).with(currency_file, 'r:ISO-8859-1').and_return(currency_csv)
    expect(CSV).to receive(:parse).with(currency_csv, {:headers=>true, :header_converters=>:symbol})
    expect(CSV).to receive(:parse).with(sales_order_file, {:headers=>true, :header_converters=>:symbol})
    subject.perform
  end

  it 'passes rows to IoCsv' do
    allow(File).to receive(:open).with(sales_order_file, 'r:ISO-8859-1').and_return sales_order_csv(sales_stage_percent: 100)
    allow(File).to receive(:open).with(currency_file, 'r:ISO-8859-1').and_return(currency_csv)
    expect(IoCsv).to receive(:new).with({
      io_external_number: nil,
      io_name: nil,
      io_start_date: nil,
      io_end_date: nil,
      io_advertiser: nil,
      io_agency: nil,
      io_budget: nil,
      io_budget_loc: nil,
      io_curr_cd: nil,
      company_id: company.id
    }).and_return(io_csv)
    expect(io_csv).to receive(:valid?).and_return(:true)
    expect(io_csv).to receive(:perform)
    subject.perform
  end

  it 'skips a row when sales_stage_percent is not 100' do
    allow(File).to receive(:open).with(sales_order_file, 'r:ISO-8859-1').and_return sales_order_csv(sales_stage_percent: 90)
    allow(File).to receive(:open).with(currency_file, 'r:ISO-8859-1').and_return(currency_csv)
    expect(IoCsv).not_to receive(:new)
    subject.perform
  end

  it 'skips a row when order_status is _deleted_' do
    allow(File).to receive(:open).with(sales_order_file, 'r:ISO-8859-1')
    .and_return sales_order_csv(sales_stage_percent: 100, order_status: 'deleted')
    allow(File).to receive(:open).with(currency_file, 'r:ISO-8859-1').and_return(currency_csv)
    expect(IoCsv).not_to receive(:new)
    subject.perform
  end

  it 'skips invalid rows' do
    allow(File).to receive(:open).with(sales_order_file, 'r:ISO-8859-1')
    .and_return sales_order_csv(sales_stage_percent: 100)
    allow(File).to receive(:open).with(currency_file, 'r:ISO-8859-1').and_return(currency_csv)
    expect(IoCsv).to receive(:new).and_return(io_csv)
    expect(io_csv).to receive(:valid?).and_return(false)
    expect(io_csv).not_to receive(:perform)
    subject.perform
  end

  it 'maps currency code from currency file' do
    allow(File).to receive(:open).with(sales_order_file, 'r:ISO-8859-1')
    .and_return sales_order_csv(sales_stage_percent: 100, order_currency_id: 100)
    allow(File).to receive(:open).with(currency_file, 'r:ISO-8859-1').and_return(currency_csv)
    expect(IoCsv).to receive(:new).with({
      io_external_number: nil,
      io_name: nil,
      io_start_date: nil,
      io_end_date: nil,
      io_advertiser: nil,
      io_agency: nil,
      io_budget: nil,
      io_budget_loc: nil,
      io_curr_cd: 'USD',
      company_id: company.id
    }).and_return(io_csv)
    expect(io_csv).to receive(:valid?).and_return(:true)
    expect(io_csv).to receive(:perform)
    subject.perform
  end

  def sales_order_csv(opts={})
    @_sales_order_csv_data ||= build :sales_order_csv_data, opts
    @_sales_order_csv ||= generate_csv(@_sales_order_csv_data)
  end

  def currency_csv(opts={})
    @_currency_csv ||= generate_csv({
      currency_id: 100,
      currency_code: 'USD'
    })
  end
end
