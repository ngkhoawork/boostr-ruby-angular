require 'rails_helper'

RSpec.describe Operative::ImportInvoiceLineItemsService, datafeed: :true do
  let(:company) { Company.first }
  let(:invoice_lines_file) { './spec/invoice_line_item_file.csv' }
  let(:invoices_file) { './spec/invoices_file.csv' }
  let(:line_item_budget_csv) { double() }

  in_directory_with_files([
    './spec/invoice_line_item_file.csv',
    './spec/invoices_file.csv',
  ])

  before do
    content_for_files([
      invoice_lines_csv_file,
      invoice_csv_file
    ])
  end

  it 'passes rows to DisplayLineItemCsv' do
    expect(DisplayLineItemBudgetCsv).to receive(:new).with(
      line_number: '2',
      budget_loc: 150.0,
      month_and_year: '01-2017',
      impressions: '150000',
      revenue_calculation_pattern: default_pattern,
      company_id: company.id
    ).and_return(line_item_budget_csv)
    expect(line_item_budget_csv).to receive(:valid?).and_return(:true)
    expect(line_item_budget_csv).to receive(:perform)
    subject.perform
  end

  context 'revenue_calculation_patterns' do
    context 'Invoice Units pattern' do
      it 'passes invoice_units divided by 1000' do
        expect(DisplayLineItemBudgetCsv).to receive(:new).with(
          line_number: '2',
          budget_loc: 150.0,
          month_and_year: '01-2017',
          impressions: '150000',
          revenue_calculation_pattern: default_pattern,
          company_id: company.id
        ).and_return(line_item_budget_csv)
        expect(line_item_budget_csv).to receive(:valid?).and_return(:true)
        expect(line_item_budget_csv).to receive(:perform)
        subject.perform
      end
    end

    context 'Recognized Revenue pattern' do
      it 'sums invoice_line_item.recognized_revenue' do
        recognized_revenue_pattern = DatafeedConfigurationDetails.get_pattern_id('Recognized Revenue')

        expect(DisplayLineItemBudgetCsv).to receive(:new).with(
          line_number: '2',
          budget_loc: 90000.0,
          month_and_year: '01-2017',
          impressions: '150000',
          revenue_calculation_pattern: recognized_revenue_pattern,
          company_id: company.id
        ).and_return(line_item_budget_csv)
        expect(line_item_budget_csv).to receive(:valid?).and_return(:true)
        expect(line_item_budget_csv).to receive(:perform)
        subject(recognized_revenue_pattern).perform
      end
    end

    context 'Invoice Amount pattern' do
      it 'sums invoice_line_item.invoice_amount' do
        invoice_amount_pattern = DatafeedConfigurationDetails.get_pattern_id('Invoice Amount')

        expect(DisplayLineItemBudgetCsv).to receive(:new).with(
          line_number: '2',
          budget_loc: 35000.0,
          month_and_year: '01-2017',
          impressions: '150000',
          revenue_calculation_pattern: invoice_amount_pattern,
          company_id: company.id
        ).and_return(line_item_budget_csv)
        expect(line_item_budget_csv).to receive(:valid?).and_return(:true)
        expect(line_item_budget_csv).to receive(:perform)
        subject(invoice_amount_pattern).perform
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

  def invoice_lines_csv_file
    @_invoice_lines_csv_file ||= generate_csv({
      invoice_id: 10,
      sales_order_line_item_id: '2',
      invoice_units: '150000',
      recognized_revenue: '90000',
      invoice_amount: '35000',
      cumulative_primary_performance: '50',
      cumulative_third_party_performance: '60'
    })
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

  def subject(revenue_calculation_pattern = default_pattern)
    @_subject ||= Operative::ImportInvoiceLineItemsService.new(
      company.id,
      revenue_calculation_pattern,
      { invoice_line_item: invoice_lines_file, invoice: invoices_file }
    )
  end
end
