require 'rails_helper'

RSpec.describe Operative::ImportSalesOrderLineItemsService, datafeed: :true do
  let!(:company) { create :company }
  let(:line_item_file) { './spec/sales_order_line_item_file.csv' }
  let(:invoice_file) { './spec/invoice_line_item_file.csv' }
  let(:line_item_csv) { double() }

  in_directory_with_files(['./spec/sales_order_line_item_file.csv', './spec/invoice_line_item_file.csv'])

  it 'passes rows to DisplayLineItemCsv' do
    content_for_files([
      line_item_csv_file,
      invoice_csv_file
    ])

    expect(DisplayLineItemCsv).to receive(:new).with(
      external_io_number: '1',
      line_number: '2',
      ad_server: 'O1',
      start_date: '2017-01-01',
      end_date: '2017-02-01',
      ad_server_product: 'Display',
      product_name: 'Display',
      quantity: '1000',
      price: '100',
      pricing_type: 'PPC',
      budget: '100000',
      budget_delivered: 1500.0,
      quantity_delivered: 50,
      quantity_delivered_3p: 60,
      company_id: company.id
    ).and_return(line_item_csv)
    expect(line_item_csv).to receive(:valid?).and_return(:true)
    expect(line_item_csv).to receive(:perform)
    subject.perform
  end

  it 'sums budget_delivered and gets last cumulative values from invoice lines' do
    content_for_files([
      line_item_csv_file,
      multiline_invoice_csv_file
    ])

    expect(DisplayLineItemCsv).to receive(:new).with(
      external_io_number: '1',
      line_number: '2',
      ad_server: 'O1',
      start_date: '2017-01-01',
      end_date: '2017-02-01',
      ad_server_product: 'Display',
      product_name: 'Display',
      quantity: '1000',
      price: '100',
      pricing_type: 'PPC',
      budget: '100000',
      budget_delivered: 30000.00,
      quantity_delivered: 4568899,
      quantity_delivered_3p: 30,
      company_id: company.id
    ).and_return(line_item_csv)
    expect(line_item_csv).to receive(:valid?).and_return(:true)
    expect(line_item_csv).to receive(:perform)
    subject.perform
  end

  it 'passes budget_delivered and quantity_delivered as zeroes if invoice is not found' do
    content_for_files([
      line_item_csv_file,
      empty_invoice_csv_file
    ])

    expect(DisplayLineItemCsv).to receive(:new).with(
      external_io_number: '1',
      line_number: '2',
      ad_server: 'O1',
      start_date: '2017-01-01',
      end_date: '2017-02-01',
      ad_server_product: 'Display',
      product_name: 'Display',
      quantity: '1000',
      price: '100',
      pricing_type: 'PPC',
      budget: '100000',
      budget_delivered: 0,
      quantity_delivered: 0,
      quantity_delivered_3p: 0,
      company_id: company.id
    ).and_return(line_item_csv)
    expect(line_item_csv).to receive(:valid?).and_return(:true)
    expect(line_item_csv).to receive(:perform)
    subject.perform
  end

  it 'skips a row when line_item_status is not production' do
    content_for_files([
      line_item_csv_file(line_item_status: 'deleted'),
      invoice_csv_file
    ])

    expect(DisplayLineItemCsv).not_to receive(:new)
    subject.perform
  end

  it 'skips a row when quantity is NULL' do
    content_for_files([
      line_item_csv_file(quantity: nil),
      invoice_csv_file
    ])

    expect(DisplayLineItemCsv).not_to receive(:new)
    subject.perform
  end

  it 'skips a row when net_cost is NULL' do
    content_for_files([
      line_item_csv_file(net_cost: nil),
      invoice_csv_file
    ])

    expect(DisplayLineItemCsv).not_to receive(:new)
    subject.perform
  end

  it 'skips a row when net_cost is 0' do
    content_for_files([
      line_item_csv_file(net_cost: '0'),
      invoice_csv_file
    ])

    expect(DisplayLineItemCsv).not_to receive(:new)
    subject.perform
  end

  it 'skips rows that got changed more than a day prior to last import' do
    api_config({skip_not_changed: true})

    csv_import_log(created_at: Date.today - 1.month)

    content_for_files([
      line_item_csv_file(last_modified_on: DateTime.now - 3.months),
      invoice_csv_file
    ])

    expect(DisplayLineItemCsv).not_to receive(:new)
    subject.perform
  end

  it 'does not skip old rows if option is disabled' do
    api_config({skip_not_changed: false})

    csv_import_log(created_at: Date.today - 1.month)

    content_for_files([
      line_item_csv_file(last_modified_on: DateTime.now - 3.months),
      invoice_csv_file
    ])

    expect(DisplayLineItemCsv).to receive(:new).and_return(line_item_csv)
    expect(line_item_csv).to receive(:valid?).and_return(:true)
    expect(line_item_csv).to receive(:perform)
    subject.perform
  end

  it 'does not skip rows that changed recently' do
    api_config({skip_not_changed: true})

    csv_import_log(created_at: Date.today - 1.month)

    content_for_files([
      line_item_csv_file(last_modified_on: DateTime.now.to_s),
      invoice_csv_file
    ])

    expect(DisplayLineItemCsv).to receive(:new).and_return(line_item_csv)
    expect(line_item_csv).to receive(:valid?).and_return(:true)
    expect(line_item_csv).to receive(:perform)
    subject.perform
  end

  it 'deletes a row when status is deleted and line exists in our system' do
    content_for_files([
      line_item_csv_file(
        sales_order_id: io.id,
        sales_order_line_item_id: display_line_item.line_number,
        line_item_status: 'deleted'
      ),
      invoice_csv_file
    ])

    subject.perform
    expect{ display_line_item.reload }.to raise_error ActiveRecord::RecordNotFound
  end

  context 'revenue_calculation_patterns' do
    context 'Invoice Units pattern' do
      it 'sums invoice_line_item.invoice_units and multiplies by net_unit_cost' do
        content_for_files([
          line_item_csv_file,
          multiline_invoice_csv_file
        ])

        expect(DisplayLineItemCsv).to receive(:new).with(
          external_io_number: '1',
          line_number: '2',
          ad_server: 'O1',
          start_date: '2017-01-01',
          end_date: '2017-02-01',
          ad_server_product: 'Display',
          product_name: 'Display',
          quantity: '1000',
          price: '100',
          pricing_type: 'PPC',
          budget: '100000',
          budget_delivered: 30000.00,
          quantity_delivered: 4568899,
          quantity_delivered_3p: 30,
          company_id: company.id
        ).and_return(line_item_csv)
        expect(line_item_csv).to receive(:valid?).and_return(:true)
        expect(line_item_csv).to receive(:perform)
        subject.perform
      end
    end

    context 'Recognized Revenue pattern' do
      it 'sums invoice_line_item.recognized_revenue' do
        pattern_id = DatafeedConfigurationDetails.get_pattern_id('Recognized Revenue')
        api_config({revenue_calculation_pattern: pattern_id})

        content_for_files([
          line_item_csv_file,
          multiline_invoice_csv_file
        ])

        expect(DisplayLineItemCsv).to receive(:new).with(
          external_io_number: '1',
          line_number: '2',
          ad_server: 'O1',
          start_date: '2017-01-01',
          end_date: '2017-02-01',
          ad_server_product: 'Display',
          product_name: 'Display',
          quantity: '1000',
          price: '100',
          pricing_type: 'PPC',
          budget: '100000',
          budget_delivered: 96109.00,
          quantity_delivered: 4568899,
          quantity_delivered_3p: 30,
          company_id: company.id
        ).and_return(line_item_csv)
        expect(line_item_csv).to receive(:valid?).and_return(:true)
        expect(line_item_csv).to receive(:perform)

        subject.perform
      end
    end

    context 'Invoice Amount pattern' do
      it 'sums invoice_line_item.invoice_amount' do
        pattern_id = DatafeedConfigurationDetails.get_pattern_id('Invoice Amount')
        api_config({revenue_calculation_pattern: pattern_id})

        content_for_files([
          line_item_csv_file,
          multiline_invoice_csv_file
        ])

        expect(DisplayLineItemCsv).to receive(:new).with(
          external_io_number: '1',
          line_number: '2',
          ad_server: 'O1',
          start_date: '2017-01-01',
          end_date: '2017-02-01',
          ad_server_product: 'Display',
          product_name: 'Display',
          quantity: '1000',
          price: '100',
          pricing_type: 'PPC',
          budget: '100000',
          budget_delivered: 9999.00,
          quantity_delivered: 4568899,
          quantity_delivered_3p: 30,
          company_id: company.id
        ).and_return(line_item_csv)
        expect(line_item_csv).to receive(:valid?).and_return(:true)
        expect(line_item_csv).to receive(:perform)

        subject.perform
      end
    end
  end

  context 'product mapping' do
    context 'Product Name mapping' do
      it 'passes Product_Name column as product_name' do
        mapping_id = DatafeedConfigurationDetails.get_product_mapping_id('Product_Name')
        api_config({product_mapping: mapping_id})

        content_for_files([
          line_item_csv_file,
          multiline_invoice_csv_file
        ])

        expect(DisplayLineItemCsv).to receive(:new).with(
          external_io_number: '1',
          line_number: '2',
          ad_server: 'O1',
          start_date: '2017-01-01',
          end_date: '2017-02-01',
          ad_server_product: 'Display',
          product_name: 'Display',
          quantity: '1000',
          price: '100',
          pricing_type: 'PPC',
          budget: '100000',
          budget_delivered: 30000.00,
          quantity_delivered: 4568899,
          quantity_delivered_3p: 30,
          company_id: company.id
        ).and_return(line_item_csv)
        expect(line_item_csv).to receive(:valid?).and_return(:true)
        expect(line_item_csv).to receive(:perform)

        subject.perform
      end
    end

    context 'Forecast Category mapping' do
      it 'passes Forecast_Category column as product_name' do
        mapping_id = DatafeedConfigurationDetails.get_product_mapping_id('Forecast_Category')
        api_config({product_mapping: mapping_id})

        content_for_files([
          line_item_csv_file,
          multiline_invoice_csv_file
        ])

        expect(DisplayLineItemCsv).to receive(:new).with(
          external_io_number: '1',
          line_number: '2',
          ad_server: 'O1',
          start_date: '2017-01-01',
          end_date: '2017-02-01',
          ad_server_product: 'Display',
          product_name: 'From Forecast Category Column',
          quantity: '1000',
          price: '100',
          pricing_type: 'PPC',
          budget: '100000',
          budget_delivered: 30000.00,
          quantity_delivered: 4568899,
          quantity_delivered_3p: 30,
          company_id: company.id
        ).and_return(line_item_csv)
        expect(line_item_csv).to receive(:valid?).and_return(:true)
        expect(line_item_csv).to receive(:perform)

        subject.perform
      end
    end
  end

  context 'parent_line_item_id option' do
    context 'exclude_child_line_items is enabled' do
      it 'skips rows if parent_line_item_id is present' do
        api_config({exclude_child_line_items: true})

        content_for_files([
          line_item_csv_file(parent_line_item_id: '50065'),
          invoice_csv_file
        ])

        expect(DisplayLineItemCsv).not_to receive(:new)
        subject.perform
      end
    end

    context 'exclude_child_line_items is disabled' do
      it 'does not skip rows if parent_line_item_id is present' do
        api_config({exclude_child_line_items: false})

        content_for_files([
          line_item_csv_file(parent_line_item_id: '50065'),
          invoice_csv_file
        ])

        expect(DisplayLineItemCsv).to receive(:new).and_return(line_item_csv)
        expect(line_item_csv).to receive(:valid?).and_return(:true)
        expect(line_item_csv).to receive(:perform)

        subject.perform
      end
    end
  end

  context 'logging the results' do
    it 'creates an import log item' do
      content_for_files([
        line_item_csv_file,
        invoice_csv_file
      ])

      expect {
        subject.perform
      }.to change(CsvImportLog, :count).by 1
    end

    it 'saves parse information to the log' do
      content_for_files([
        multyline_line_item_csv_file,
        invoice_csv_file
      ])

      subject.perform

      import_log = CsvImportLog.last
      expect(import_log.rows_processed).to eq 8
      expect(import_log.rows_imported).to eq 4
      expect(import_log.rows_failed).to eq 2
      expect(import_log.rows_skipped).to eq 1

      expect(import_log.error_messages.length).to eq 2
      expect(import_log.error_messages[0]['message']).to include("Product name can't be blank")
      expect(import_log.error_messages[1]['message']).to include("Product name can't be blank")

      expect(import_log.file_source).to eq 'sales_order_line_item_file.csv'

      expect(import_log.object_name).to eq 'display_line_item'
    end

    it 'catches internal server errors' do
      content_for_files([
        line_item_csv_file,
        invoice_csv_file
      ])

      expect(DisplayLineItemCsv).to receive(:new).and_return(line_item_csv)
      expect(line_item_csv).to receive(:valid?).and_return(:true)
      expect(line_item_csv).to receive(:perform).and_raise(ActiveRecord::RecordNotFound)

      subject.perform

      import_log = CsvImportLog.last
      expect(import_log.error_messages).to eq [{"row"=>2, "message"=>["Internal Server Error", "{:sales_order_id=>\"1\", :sales_order_line_item_id=>\"2\", :sales_order_line_item_start_date=>\"2017-01-01\", :sales_order_line_item_end_date=>\"2017-02-01\", :product_name=>\"Display\", :forecast_category=>\"From Forecast Category Column\", :quantity=>\"1000\", :net_unit_cost=>\"100\", :cost_type=>\"PPC\", :net_cost=>\"100000\", :line_item_status=>\"Sent_to_production\"}"]}]
    end
  end

  def io(opts= {})
    opts[:company_id] = company.id
    @_io = create :io, opts
  end

  def start_date
    @start_date ||= Date.current
  end

  def end_date
    @end_date ||= start_date + 1.day
  end

  def line_item_csv_file(opts = {})
    @_line_item_csv_file ||= generate_csv({
      sales_order_id: '1',
      sales_order_line_item_id: '2',
      sales_order_line_item_start_date: '2017-01-01',
      sales_order_line_item_end_date: '2017-02-01',
      product_name: 'Display',
      forecast_category: 'From Forecast Category Column',
      quantity: '1000',
      net_unit_cost: '100',
      cost_type: 'PPC',
      net_cost: '100000',
      line_item_status: 'Sent_to_production'
    }.merge(opts))
  end

  def multyline_line_item_csv_file
    io(start_date: Date.today, end_date: Date.today)

    list = (build_list :sales_order_line_item_csv_data, 4,
      sales_order_id: io(start_date: start_date, end_date: end_date).external_io_number,
      sales_order_line_item_id: 2,
      sales_order_line_item_start_date: start_date + 1.day,
      sales_order_line_item_end_date: end_date - 1.day,
      product_name: 'Display',
      quantity: 1000,
      net_unit_cost: 100,
      cost_type: 'PPC',
      net_cost: 100000,
      line_item_status: 'Sent_to_production'
    )

    list.concat (build_list :sales_order_line_item_csv_data, 2,
      sales_order_id: io(start_date: start_date, end_date: end_date).external_io_number,
      sales_order_line_item_id: 2,
      sales_order_line_item_start_date: start_date + 1.day,
      sales_order_line_item_end_date: end_date + 1.day,
      product_name: nil,
      quantity: 1000,
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
      invoice_units: '15000',
      cumulative_primary_performance: '50',
      cumulative_third_party_performance: '60'
    })
  end

  def multiline_invoice_csv_file
    keys = [:sales_order_line_item_id, :invoice_units, :cumulative_primary_performance, :cumulative_third_party_performance, :recognized_revenue, :invoice_amount]
    values = [
      ['2', '150000', '916306', '10', '71199', '1231'],
      ['2', '100000', '4568899', '20', '11999', '3213'],
      ['2', '50000', '4568899', '30', '12911', '5555']
    ]
    @_invoice_csv_file ||= generate_multiline_csv(keys, values)
  end

  def empty_invoice_csv_file
    @empty_invoice_csv_file ||= generate_csv({
      sales_order_line_item_id: '0',
      invoice_units: '15000',
      cumulative_primary_performance: '50',
      cumulative_third_party_performance: '60'
    })
  end

  def default_pattern
    DatafeedConfigurationDetails.get_pattern_id('Invoice Units')
  end

  def default_mapping
    DatafeedConfigurationDetails.get_product_mapping_id('Product_Name')
  end

  def subject
    @_subject ||= Operative::ImportSalesOrderLineItemsService.new(
      api_config,
      { sales_order_line_items: line_item_file, invoice_line_item: invoice_file }
    )
  end

  def display_line_item
    @display_line_item ||= create :display_line_item, io: io
  end

  def api_config(opts={})
    @api_config ||= create :operative_datafeed_configuration, {
      company: company,
      datafeed_configuration_details: datafeed_configuration_details(opts)
    }
  end

  def datafeed_configuration_details(opts={})
    defaults = {
      revenue_calculation_pattern: default_pattern,
      product_mapping: default_mapping,
      exclude_child_line_items: false
    }

    @details ||= create :datafeed_configuration_details, defaults.merge(opts)
  end

  def csv_import_log(opts={})
    defaults = {
      company_id: company.id,
      object_name: 'display_line_item',
      source: 'operative',
      rows_processed: 11
    }

    @csv_import_log ||= create :csv_import_log, defaults.merge(opts)
  end
end
