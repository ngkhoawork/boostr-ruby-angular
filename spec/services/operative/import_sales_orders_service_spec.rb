require 'rails_helper'

RSpec.describe Operative::ImportSalesOrdersService, datafeed: :true do
  subject(:subject) { Operative::ImportSalesOrdersService.new(sales_order_file) }
  let(:company) { Company.first }
  let(:sales_order_file) { './datafeed/sales_order_file.csv' }
  let(:io_csv) { double() }

  it 'opens file' do
    expect(File).to receive(:open).with(sales_order_file, 'r:ISO-8859-1').and_return(sales_order_file)
    subject.perform
  end

  it 'parses CSV file' do
    allow(File).to receive(:open).with(sales_order_file, 'r:ISO-8859-1').and_return(sales_order_file)
    expect(CSV).to receive(:parse).with(sales_order_file, {:headers=>true, :header_converters=>:symbol})
    subject.perform
  end

  it 'passes rows to IoCsv' do
    allow(File).to receive(:open).with(sales_order_file, 'r:ISO-8859-1').and_return(csv_file)
    expect(IoCsv).to receive(:new).with({
      io_external_number: nil,
      io_name: nil,
      io_start_date: nil,
      io_end_date: nil,
      io_advertiser: nil,
      io_agency: nil,
      io_budget: nil,
      io_budget_loc: nil,
      io_curr_cd: nil
    }).and_return(io_csv)
    expect(io_csv).to receive(:perform)
    subject.perform
  end

  def csv_file
    @_csv_file ||= generate_csv({empty_csv: 'empty'})
  end
end
