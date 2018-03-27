require 'rails_helper'

RSpec.describe Operative::ImportSalesOrdersService, datafeed: :true do
  subject(:subject) {
    Operative::ImportSalesOrdersService.new(
      company.id,
      auto_close_deals,
      {sales_order: sales_order_file, currency: currency_file}
    )
  }
  let!(:company) { create :company }
  let(:auto_close_deals) { true }
  let(:sales_order_file) { './spec/sales_order_file.csv' }
  let(:currency_file)    { './spec/currency_file.csv' }
  let(:io_csv)           { double() }

  in_directory_with_files(['./spec/sales_order_file.csv', './spec/currency_file.csv'])

  it 'passes rows to IoCsv' do
    content_for_files([
      sales_order_csv(exchange_rate_at_close: 1.55),
      currency_csv
    ])

    expect(IoCsv).to receive(:new).with({
      io_external_number: nil,
      io_name: nil,
      io_start_date: (Date.today - 1.month).to_s,
      io_end_date: nil,
      io_advertiser: nil,
      io_agency: nil,
      io_budget: nil,
      io_budget_loc: nil,
      io_curr_cd: nil,
      company_id: company.id,
      auto_close_deals: true,
      exchange_rate: "1.55"
    }).and_return(io_csv)
    expect(io_csv).to receive(:valid?).and_return(:true)
    expect(io_csv).to receive(:perform)
    subject.perform
  end

  it 'skips a row when sales_stage_percent is not 100' do
    content_for_files([
      sales_order_csv(sales_stage_percent: 90),
      currency_csv
    ])

    expect(IoCsv).not_to receive(:new)
    subject.perform
  end

  it 'skips a row when order_start_date is empty' do
    content_for_files([
      sales_order_csv(order_start_date: ''),
      currency_csv
    ])

    expect(IoCsv).not_to receive(:new)
    subject.perform
  end

  it 'skips a row when order_status is deleted' do
    content_for_files([
      sales_order_csv(order_status: 'deleted'),
      currency_csv
    ])

    expect(IoCsv).not_to receive(:new)
    subject.perform
  end

  it 'skips invalid rows' do
    content_for_files([
      sales_order_csv,
      currency_csv
    ])

    expect(IoCsv).to receive(:new).and_return(io_csv)
    expect(io_csv).to receive(:valid?).and_return(false)
    expect(io_csv).to receive(:errors).and_return(io_csv)
    expect(io_csv).to receive(:full_messages).and_return('')
    expect(io_csv).not_to receive(:perform)
    subject.perform
  end

  it 'maps currency code from currency file' do
    content_for_files([
      sales_order_csv(order_currency_id: 100),
      currency_csv
    ])

    expect(IoCsv).to receive(:new).with({
      io_external_number: nil,
      io_name: nil,
      io_start_date: (Date.today - 1.month).to_s,
      io_end_date: nil,
      io_advertiser: nil,
      io_agency: nil,
      io_budget: nil,
      io_budget_loc: nil,
      io_curr_cd: 'USD',
      company_id: company.id,
      auto_close_deals: true,
      exchange_rate: nil
    }).and_return(io_csv)
    expect(io_csv).to receive(:valid?).and_return(:true)
    expect(io_csv).to receive(:perform)
    subject.perform
  end

  context 'logging the results' do
    it 'creates an import log item' do
      content_for_files([
        sales_order_csv(order_currency_id: 100),
        currency_csv
      ])

      expect {
        subject.perform
      }.to change(CsvImportLog, :count).by 1
    end

    it 'saves parse information to the log' do
      content_for_files([
        multyline_order_csv,
        currency_csv
      ])

      subject.perform

      import_log = CsvImportLog.last
      expect(import_log.rows_processed).to eq 8
      expect(import_log.rows_imported).to eq 4
      expect(import_log.rows_failed).to eq 2
      expect(import_log.rows_skipped).to eq 1
      expect(import_log.error_messages).to eq [{"row"=>6, "message"=>["Io advertiser can't be blank"]}, {"row"=>7, "message"=>["Io name can't be blank"]}]
      expect(import_log.file_source).to eq 'sales_order_file.csv'
      expect(import_log.object_name).to eq 'io'
    end

    it 'catches internal server errors' do
      content_for_files([
        sales_order_csv(order_currency_id: 100),
        currency_csv
      ])

      expect(IoCsv).to receive(:new).and_return io_csv
      expect(io_csv).to receive(:valid?).and_return(:true)
      expect(io_csv).to receive(:perform).and_raise(ActiveRecord::RecordNotFound)

      subject.perform
      import_log = CsvImportLog.last
      expect(import_log.error_messages).to eq [{
        "row"=>2,
        "message"=>
          ["Internal Server Error", "{:order_currency_id=>\"100\", :order_start_date=>\"#{Date.today - 1.month}\", :sales_stage_percent=>\"100\"}"]
      }]
    end

    it 'catches and processes amendable csv rows' do
      content_for_files([
        amendable_malformed_csv,
        currency_csv
      ])

      subject.perform
      import_log = CsvImportLog.last
      expect(import_log.error_messages).not_to be_present

      expect(import_log.rows_processed).to eq 3
      expect(import_log.rows_imported).to  eq 2
    end

    it 'catches and skips malformed csv rows' do
      content_for_files([
        malformed_csv,
        currency_csv
      ])

      subject.perform
      import_log = CsvImportLog.last
      expect(import_log.error_messages).to eq [{
        "row"=>2,
        "message"=>
          ["Unclosed quoted field on line 1.",
            "\"(To Be Malformed\"\",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n"]
      }]
      expect(import_log.rows_processed).to eq 3
      expect(import_log.rows_imported).to  eq 1
    end
  end

  def sales_order_csv(opts={})
    defaults = {
      sales_stage_percent: '100',
      order_start_date: Date.today - 1.month
    }

    @_sales_order_csv_data ||= build :sales_order_csv_data, defaults.merge(opts)
    @_sales_order_csv ||= generate_csv(@_sales_order_csv_data)
  end

  def currency_csv(opts={})
    @_currency_csv ||= generate_csv({
      currency_id: 100,
      currency_code: 'USD'
    })
  end

  def multyline_order_csv
    list = (build_list :sales_order_csv_data, 4, valid_order_data)

    list << (build :sales_order_csv_data,
      sales_stage_percent: 100,
      sales_order_id: 101,
      sales_order_name: 'Order_name_4141',
      order_start_date: Date.today - 1.month,
      order_end_date: Date.today,
      total_order_value: '5000',
      order_currency_id: 100
    )

    list << (build :sales_order_csv_data,
      sales_stage_percent: 100,
      sales_order_id: 101,
      order_start_date: Date.today - 1.month,
      order_end_date: Date.today,
      advertiser_name: 'Test',
      total_order_value: '5000',
      order_currency_id: 100
    )

    list << (build :sales_order_csv_data, sales_stage_percent: 90)
    @_multyline_order_csv ||= generate_multiline_csv(list.first.keys, list.map(&:values))
  end

  def malformed_csv
    list = []
    list << (build :sales_order_csv_data, sales_order_id: '(To Be Malformed"')
    list << (build :sales_order_csv_data, valid_order_data)
    @_malformed_csv ||= generate_multiline_csv(list.first.keys, list.map(&:values)).gsub("\"\"", "\"")
    @_malformed_csv
  end

  def amendable_malformed_csv
    list = []
    malformed = valid_order_data
    malformed[:sales_order_name] = "Very \"Illegal\" Quoting"
    list << (build :sales_order_csv_data, malformed)
    list << (build :sales_order_csv_data, valid_order_data)
    @_amendable_malformed_csv ||= generate_multiline_csv(list.first.keys, list.map(&:values)).gsub("\"\"", "\"")
    @_amendable_malformed_csv
  end

  def valid_order_data
    {
      sales_stage_percent: 100,
      sales_order_id: 101,
      sales_order_name: 'Order_name_4141',
      order_start_date: Date.today - 1.month,
      order_end_date: Date.today,
      advertiser_name: 'Test',
      agency_name: nil,
      total_order_value: '5000',
      order_currency_id: 100
    }
  end
end
