require 'rails_helper'

RSpec.describe Operative::ImportInvoiceLineItemsService, datafeed: :true do
  let!(:company) { create :company }
  let(:invoice_lines_file) { './spec/invoice_line_item_file.csv' }
  let(:invoices_file) { './spec/invoices_file.csv' }
  let(:line_item_budget_csv) { double() }

  in_directory_with_files([
    './spec/invoice_line_item_file.csv',
    './spec/invoices_file.csv',
  ])

  it 'passes rows to DisplayLineItemCsv' do
    expect(DisplayLineItemBudgetCsv).to receive(:new).with(
      invoice_id: '10',
      line_number: '2',
      budget_loc: 150.0,
      month_and_year: '01-2017',
      impressions: '150000',
      revenue_calculation_pattern: default_pattern,
      company_id: company.id
    ).and_return(line_item_budget_csv)
    expect(line_item_budget_csv).to receive(:irrelevant?).and_return(false)
    expect(line_item_budget_csv).to receive(:valid?).and_return(true)
    expect(line_item_budget_csv).to receive(:perform)
    subject.perform
  end

  it 'skips rows that got changed more than a day prior to last import' do
    api_config({ skip_not_changed: true })

    csv_import_log(created_at: Date.today - 1.month)

    expect(DisplayLineItemBudgetCsv).not_to receive(:new)
    subject(last_modified_on: DateTime.now - 3.months).perform
  end

  it 'does not skip old rows if option is disabled' do
    api_config({skip_not_changed: false})

    csv_import_log(created_at: Date.today - 1.month)

    expect(DisplayLineItemBudgetCsv).to receive(:new).and_return(line_item_budget_csv)
    expect(line_item_budget_csv).to receive(:irrelevant?).and_return(false)
    expect(line_item_budget_csv).to receive(:valid?).and_return(true)
    expect(line_item_budget_csv).to receive(:perform)
    subject(last_modified_on: DateTime.now - 3.months).perform
  end

  it 'does not skip rows that changed recently' do
    api_config({skip_not_changed: true})

    csv_import_log(created_at: Date.today - 1.month)

    expect(DisplayLineItemBudgetCsv).to receive(:new).and_return(line_item_budget_csv)
    expect(line_item_budget_csv).to receive(:irrelevant?).and_return(false)
    expect(line_item_budget_csv).to receive(:valid?).and_return(true)
    expect(line_item_budget_csv).to receive(:perform)
    subject(last_modified_on: DateTime.now.to_s).perform
  end

  context 'revenue_calculation_patterns' do
    context 'Invoice Units pattern' do
      it 'passes invoice_units divided by 1000' do
        expect(DisplayLineItemBudgetCsv).to receive(:new).with(
          invoice_id: '10',
          line_number: '2',
          budget_loc: 150.0,
          month_and_year: '01-2017',
          impressions: '150000',
          revenue_calculation_pattern: default_pattern,
          company_id: company.id
        ).and_return(line_item_budget_csv)
        expect(line_item_budget_csv).to receive(:irrelevant?).and_return(false)
        expect(line_item_budget_csv).to receive(:valid?).and_return(:true)
        expect(line_item_budget_csv).to receive(:perform)
        subject.perform
      end
    end

    context 'Recognized Revenue pattern' do
      it 'sums invoice_line_item.recognized_revenue' do
        revenue_pattern = DatafeedConfigurationDetails.get_pattern_id('Recognized Revenue')
        api_config(revenue_calculation_pattern: revenue_pattern)

        expect(DisplayLineItemBudgetCsv).to receive(:new).with(
          invoice_id: '10',
          line_number: '2',
          budget_loc: 90000.0,
          month_and_year: '01-2017',
          impressions: '150000',
          revenue_calculation_pattern: revenue_pattern,
          company_id: company.id
        ).and_return(line_item_budget_csv)
        expect(line_item_budget_csv).to receive(:irrelevant?).and_return(false)
        expect(line_item_budget_csv).to receive(:valid?).and_return(:true)
        expect(line_item_budget_csv).to receive(:perform)
        subject.perform
      end

      it 'multiplies recognized revenue by the recognized revenue adjustement' do
        revenue_pattern = DatafeedConfigurationDetails.get_pattern_id('Recognized Revenue')
        api_config(revenue_calculation_pattern: revenue_pattern)

        expect(DisplayLineItemBudgetCsv).to receive(:new).with(
          invoice_id: '10',
          line_number: '2',
          budget_loc: 100000.0,
          month_and_year: '01-2017',
          impressions: '150000',
          revenue_calculation_pattern: revenue_pattern,
          company_id: company.id
        ).and_return(line_item_budget_csv)
        expect(line_item_budget_csv).to receive(:irrelevant?).and_return(false)
        expect(line_item_budget_csv).to receive(:valid?).and_return(:true)
        expect(line_item_budget_csv).to receive(:perform)
        subject(recognized_revenue_adjustment: 10000).perform
      end
    end

    context 'Invoice Amount pattern' do
      it 'sums invoice_line_item.invoice_amount' do
        revenue_pattern = DatafeedConfigurationDetails.get_pattern_id('Invoice Amount')
        api_config(revenue_calculation_pattern: revenue_pattern)

        expect(DisplayLineItemBudgetCsv).to receive(:new).with(
          invoice_id: '10',
          line_number: '2',
          budget_loc: 35000.0,
          month_and_year: '01-2017',
          impressions: '150000',
          revenue_calculation_pattern: revenue_pattern,
          company_id: company.id
        ).and_return(line_item_budget_csv)
        expect(line_item_budget_csv).to receive(:irrelevant?).and_return(false)
        expect(line_item_budget_csv).to receive(:valid?).and_return(:true)
        expect(line_item_budget_csv).to receive(:perform)
        subject.perform
      end
    end
  end

  context 'logging the results' do
    it 'creates an import log item' do
      expect {
        subject.perform
      }.to change(CsvImportLog, :count).by 1
    end
  end

  def invoice_lines_csv_file(opts)
    @_invoice_lines_csv_file ||= generate_csv({
      invoice_id: 10,
      sales_order_line_item_id: '2',
      invoice_units: '150000',
      recognized_revenue: '90000',
      invoice_amount: '35000',
      cumulative_primary_performance: '50',
      cumulative_third_party_performance: '60',
      recognized_revenue_adjustment: nil
    }.merge(opts))
  end

  def invoice_csv_file
    @_invoice_csv_file ||= generate_csv({
      invoice_id: '10',
      billing_period_name: '01-2017'
    })
  end

  def default_pattern
    DatafeedConfigurationDetails.get_pattern_id('Invoice Units')
  end

  def subject(opts={})
    content_for_files([
      invoice_lines_csv_file(opts),
      invoice_csv_file
    ])

    @_subject ||= Operative::ImportInvoiceLineItemsService.new(
      api_config,
      { invoice_line_item: invoice_lines_file, invoice: invoices_file }
    )
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
      skip_not_changed: false
    }

    @details ||= create :datafeed_configuration_details, defaults.merge(opts)
  end

  def csv_import_log(opts={})
    defaults = {
      company_id: company.id,
      object_name: 'display_line_item_budget',
      source: 'operative'
    }

    @csv_import_log ||= create :csv_import_log, defaults.merge(opts)
  end
end
