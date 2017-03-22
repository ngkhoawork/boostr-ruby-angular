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
    expect(line_item_csv).to receive(:valid?).and_return(:true)
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

  context 'logging the results' do
    it 'creates an import log item' do
      allow(File).to receive(:open).with(line_item_file, 'r:ISO-8859-1').and_return(line_item_csv_file)
      allow(File).to receive(:open).with(invoice_file, 'r:ISO-8859-1').and_return(invoice_csv_file)
      expect {
        subject.perform
      }.to change(CsvImportLog, :count).by 1
    end

    it 'saves parse information to the log' do
      allow(File).to receive(:open).with(line_item_file, 'r:ISO-8859-1').and_return(multyline_line_item_csv_file)
      allow(File).to receive(:open).with(invoice_file, 'r:ISO-8859-1').and_return(invoice_csv_file)
      subject.perform

      import_log = CsvImportLog.last
      expect(import_log.rows_processed).to eq 7
      expect(import_log.rows_imported).to eq 4
      expect(import_log.rows_failed).to eq 2
      expect(import_log.rows_skipped).to eq 1
      expect(import_log.error_messages).to eq [{"row"=>5, "message"=>["Budget can't be blank", "Budget is not a number"]}, {"row"=>6, "message"=>["Quantity can't be blank", "Quantity is not a number"]}]
      expect(import_log.file_source).to eq 'sales_order_line_item_file.csv'
      expect(import_log.object_name).to eq 'display_line_item'
    end

    it 'catches internal server errors' do
      allow(File).to receive(:open).with(line_item_file, 'r:ISO-8859-1').and_return(line_item_csv_file)
      allow(File).to receive(:open).with(invoice_file, 'r:ISO-8859-1').and_return(invoice_csv_file)
      expect(DisplayLineItemCsv).to receive(:new).and_return(line_item_csv)
      expect(line_item_csv).to receive(:valid?).and_return(:true)
      expect(line_item_csv).to receive(:perform).and_raise(ActiveRecord::RecordNotFound)

      subject.perform
      import_log = CsvImportLog.last
      expect(import_log.error_messages).to eq [{"row"=>1, "message"=>["Internal Server Error", "{:sales_order_id=>\"1\", :sales_order_line_item_id=>\"2\", :sales_order_line_item_start_date=>\"2017-01-01\", :sales_order_line_item_end_date=>\"2017-02-01\", :product_name=>\"Display\", :quantity=>\"1000\", :net_unit_cost=>\"100\", :cost_type=>\"PPC\", :net_cost=>\"100000\", :line_item_status=>\"Sent_to_production\"}"]}]
    end
  end

  def io(opts= {})
    opts[:company_id] = company.id
    @_io = create :io, opts
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

  def multyline_line_item_csv_file
    list = (build_list :sales_order_line_item_csv_data, 4,
      sales_order_id: io.external_io_number,
      sales_order_line_item_id: 2,
      sales_order_line_item_start_date: Date.today - 1.month,
      sales_order_line_item_end_date: Date.today,
      product_name: 'Display',
      quantity: 1000,
      net_unit_cost: 100,
      cost_type: 'PPC',
      net_cost: 100000,
      line_item_status: 'Sent_to_production'
    )

    list << (build :sales_order_line_item_csv_data,
      sales_order_id: io.external_io_number,
      sales_order_line_item_id: 2,
      sales_order_line_item_start_date: Date.today - 1.month,
      sales_order_line_item_end_date: Date.today,
      product_name: 'Display',
      quantity: 1000,
      net_unit_cost: 100,
      cost_type: 'PPC',
      line_item_status: 'Sent_to_production'
    )

    list << (build :sales_order_line_item_csv_data,
      sales_order_id: io.external_io_number,
      sales_order_line_item_id: 2,
      sales_order_line_item_start_date: Date.today - 1.month,
      sales_order_line_item_end_date: Date.today,
      product_name: 'Display',
      net_unit_cost: 100,
      cost_type: 'PPC',
      net_cost: 100000,
      line_item_status: 'Sent_to_production'
    )

    list << (build :sales_order_line_item_csv_data, sales_order_id: io.external_io_number, line_item_status: 'deleted')
    @_multyline_order_csv ||= generate_multiline_csv(list.first.keys, list.map(&:values))
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
