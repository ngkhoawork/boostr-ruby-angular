require 'rails_helper'

RSpec.describe DFP::CumulativeImportService, dfp: :true do
  subject(:subject) {
    DFP::CumulativeImportService.new(company.id, 'dfp_cumulative', report_file: report_file)
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

  context 'logging the results' do
    it 'creates an import log item' do
      allow(File).to receive(:open).with(report_file, 'r:ISO-8859-1').and_return(report_csv)
      expect {
        subject.perform
      }.to change(CsvImportLog, :count).by 1
    end

    it 'saves parse information to the log' do
      allow(File).to receive(:open).with(report_file, 'r:ISO-8859-1').and_return(multiline_report_csv)
      subject.perform

      import_log = CsvImportLog.last
      expect(import_log.rows_processed).to eq 6
      expect(import_log.rows_imported).to eq 4
      expect(import_log.rows_failed).to eq 2
      expect(import_log.rows_skipped).to eq 0
      expect(import_log.error_messages).to eq [{"row"=>5, "message"=>["Budget can't be blank", "Budget is not a number"]}, {"row"=>6, "message"=>["Quantity can't be blank", "Quantity is not a number"]}]
      expect(import_log.file_source).to eq 'report_file.csv'
      expect(import_log.object_name).to eq 'dfp_cumulative'
    end

    it 'catches internal server errors' do
      allow(File).to receive(:open).with(report_file, 'r:ISO-8859-1').and_return(report_csv)
      expect(DisplayLineItemCsv).to receive(:new).and_return(line_item_csv)
      expect(line_item_csv).to receive(:valid?).and_return(:true)
      expect(line_item_csv).to receive(:perform).and_raise(ActiveRecord::RecordNotFound)

      subject.perform
      import_log = CsvImportLog.last
      error = import_log.error_messages.first

      expect(error["row"]).to be 1
      expect(error["message"]).to include('Internal Server Error')
      expect(error["message"][1]).to eq parsed_row
    end
  end

  def parsed_row
    CSV.parse(report_csv, { headers: true, header_converters: :symbol }).first.to_h.compact.to_s
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

  def multiline_report_csv
    list = build_list :dfp_report_cummulative_csv_data, 4,
      dimensionorder_id: io.external_io_number,
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

    list << (build :dfp_report_cummulative_csv_data,
      dimensionorder_id: io.external_io_number,
      dimensionline_item_name: "Hershey test - In-Feed - :30 - iOS",
      dimensionline_item_id: "1170022354",
      dimensionattributeline_item_start_date_time: "2016-10-31T00:00:00-07:00",
      dimensionattributeline_item_end_date_time: "2016-11-27T23:59:00-08:00",
      dimensionattributeline_item_cost_type: "CPM",
      dimensionattributeline_item_cost_per_unit: "20000000",
      dimensionattributeline_item_goal_quantity: "85000",
      dimensionattributeline_item_non_cpd_booked_revenue: nil,
      columntotal_line_item_level_impressions: "85001",
      columntotal_line_item_level_clicks: "977",
      columntotal_line_item_level_ctr: "0.0115",
      columntotal_line_item_level_all_revenue: "1700020000"
    )

    list << (build :dfp_report_cummulative_csv_data,
      dimensionorder_id: io.external_io_number,
      dimensionline_item_name: "Hershey test - In-Feed - :30 - iOS",
      dimensionline_item_id: "1170022354",
      dimensionattributeline_item_start_date_time: "2016-10-31T00:00:00-07:00",
      dimensionattributeline_item_end_date_time: "2016-11-27T23:59:00-08:00",
      dimensionattributeline_item_cost_type: "CPM",
      dimensionattributeline_item_cost_per_unit: "20000000",
      dimensionattributeline_item_goal_quantity: nil,
      dimensionattributeline_item_non_cpd_booked_revenue: "1700000000",
      columntotal_line_item_level_impressions: "85001",
      columntotal_line_item_level_clicks: "977",
      columntotal_line_item_level_ctr: "0.0115",
      columntotal_line_item_level_all_revenue: "1700020000"
    )

    @_multiline_report_csv ||= generate_multiline_csv(list.first.keys, list.map(&:values))
  end

  def line_item_csv
    @_line_item_csv ||= double('line_item_csv', valid?: true)
  end

  def io(opts= {})
    opts[:company_id] = company.id
    @_io = create :io, opts
  end
end
