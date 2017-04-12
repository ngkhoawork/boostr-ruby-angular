require 'rails_helper'

RSpec.describe DFP::CumulativeImportService, dfp: :true do
  subject(:subject) {
    DFP::CumulativeImportService.new(company.id, report_file: report_file)
  }

  it 'opens file' do
    expect(File).to receive(:open).with(report_file, 'r:ISO-8859-1').and_return(report_file)
    subject.perform
  end

  it 'parses CSV file' do
    allow(File).to receive(:open).with(report_file, 'r:ISO-8859-1').and_return(report_file)
    expect(CSV).to receive(:parse).with(report_file, {:headers=>true, :header_converters=>:symbol})
    subject.perform
  end

  it 'passes rows to DisplayLineItemCsv' do
    allow(File).to receive(:open).with(report_file, 'r:ISO-8859-1').and_return(report_csv)

    expect(DisplayLineItemCsv).to receive(:new).with(
      external_io_number: '605084194',
      product_name: 'Hershey test - In-Feed - :30 - iOS',
      line_number: '1170022354',
      ad_server: 'DFP',
      start_date: '2016-10-31T00:00:00-07:00',
      end_date: '2016-11-27T23:59:00-08:00',
      pricing_type: 'CPM',
      price: '20000000',
      quantity: '85000',
      budget: '1700000000',
      quantity_delivered: '85001',
      clicks: '977',
      ctr: '0.0115',
      budget_delivered: '1700020000',
      company_id: company.id
    ).and_return(line_item_csv)
    expect(line_item_csv).to receive(:valid?)
    expect(line_item_csv).to receive(:perform)
    subject.perform
  end

  def company
    @_company ||= create :company
  end

  def report_file
    './tmp/report_file.csv'
  end

  def report_csv(opts = {})
    @_report_csv ||= generate_csv(
      build :dfp_report_cummulative_csv_data,
        dimensionorder_id: "605084194",
        dimensionline_item_name: "Hershey test - In-Feed - :30 - iOS",
        dimensionline_item_id: "1170022354",
        dimensionattributeline_item_start_date_time: "2016-10-31T00:00:00-07:00",
        dimensionattributeline_item_end_date_time: "2016-11-27T23:59:00-08:00",
        dimensionattributeline_item_cost_type: "CPM",
        dimensionattributeline_item_cost_per_unit: "20000000",
        dimensionattributeline_item_goal_quantity: "85000",
        dimensionattributeline_item_non_cpd_booked_revenue: "1700000000",
        columntotal_line_item_level_impressions: "85001",
        columntotal_line_item_level_clicks: "977",
        columntotal_line_item_level_ctr: "0.0115",
        columntotal_line_item_level_all_revenue: "1700020000"
    )
  end

  def line_item_csv
    @_line_item_csv ||= double('line_item_csv', valid?: true)
  end
end
