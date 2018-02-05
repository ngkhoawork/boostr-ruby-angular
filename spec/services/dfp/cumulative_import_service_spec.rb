require 'rails_helper'

RSpec.describe DFP::CumulativeImportService, dfp: :true do
  subject(:subject) {
    DFP::CumulativeImportService.new(company.id, 'dfp_cumulative', report_file: report_file)
  }

  before do
    dfp_api_configuration(0)
  end

  it 'opens file' do
    expect(File).to receive(:open).with(report_file, 'r:ISO-8859-1').and_return(report_file)
    subject.perform
  end

  it 'parses CSV file' do
    allow(File).to receive(:open).with(report_file, 'r:ISO-8859-1').and_return(report_file)
    expect(CSV).to receive(:parse).with(report_file, {:headers=>true, :header_converters=>:symbol})
    subject.perform
  end

  context 'CPM product in a row' do
    xit 'creates a temp io and display line item with proper attributes' do
      allow(File).to receive(:open).with(report_file, 'r:ISO-8859-1').and_return(report_csv)

      expect(DisplayLineItemCsv).to receive(:new).with(
        io_name: 'ioname',
        io_advertiser: 'Advertiser name',
        io_agency: 'Agency name',
        io_start_date: start_date,
        io_end_date: end_date,
        line_number: 1170022354,
        ad_server: 'DFP',
        start_date: start_date,
        end_date: end_date,
        external_io_number: 605084194,
        product_name: 'Hershey test - In-Feed - :30 - iOS',
        pricing_type: 'CPM',
        price: 20000000 / 1_000_000,
        quantity: 85000,
        budget: (1700000000 / 1_000_000).to_f,
        quantity_delivered: [85000, 85001].min,
        clicks: 977,
        ctr: 0.0115,
        budget_delivered: (20000000 / 1_000_000 * 85001 / 1_000),
        company_id: company.id,
        ad_unit_name: nil,
        product_id: nil
      ).and_return(line_item_csv)
      subject.perform
    end
  end

  it 'maps CPM product to DisplayLineItemCsv' do
    allow(File).to receive(:open).with(report_file, 'r:ISO-8859-1').and_return(report_csv)

    subject.perform
  end

  it 'maps CPD product to DisplayLineItemCsv' do
    allow(File).to receive(:open).with(report_file, 'r:ISO-8859-1').and_return(report_csv_cpd)

    expect(DisplayLineItemCsv).to receive(:new).with(
      io_name: 'ioname',
      io_advertiser: 'Advertiser name',
      io_agency: 'Agency name',
      io_start_date: start_date,
      io_end_date: end_date,
      external_io_number: 605084194,
      product_name: 'Hershey test - In-Feed - :30 - iOS',
      line_number: 1170022354,
      ad_server: 'DFP',
      start_date: start_date,
      end_date: end_date,
      pricing_type: 'CPD',
      price: 20000000 / 1_000_000,
      quantity: 85000,
      budget: 20000000 / 1_000_000,
      quantity_delivered: 85000,
      clicks: 977,
      ctr: 0.0115,
      budget_delivered: 20000000 / 1_000_000,
      company_id: company.id,
      ad_unit_name: nil,
      product_id: nil
    ).and_return(line_item_csv)

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
      expect(import_log.rows_processed).to eq 3
      expect(import_log.rows_imported).to eq 1
      expect(import_log.rows_failed).to eq 2
      expect(import_log.rows_skipped).to eq 0
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

      expect(error["row"]).to eq('1')
      expect(error["message"]).to include('ActiveRecord::RecordNotFound')
    end
  end

  private

  def parsed_row
    CSV.parse(report_csv, { headers: true, header_converters: :symbol }).first.to_h.compact.to_s
  end

  def company
    @_company ||= create :company
  end

  def dfp_api_configuration(adjustment=0)
    @_dfp_api_configuration ||= create :dfp_api_configuration,
    company: company,
    cpm_budget_adjustment_attributes: {
      percentage: adjustment
    }
  end

  def report_file
    './tmp/report_file.csv'
  end

  def convert_to_utc(time_str)
    Time.strptime(time_str, '%Y-%m-%dT%H:%M:%S%z').in_time_zone(Time.zone)
  end

  def report_csv(opts = {})
    @_report_csv ||= generate_csv(
      build :dfp_report_cummulative_csv_data,
        dimensionorder_name: 'ioname',
        dimensionadvertiser_name: 'Advertiser name',
        dimensionattributeorder_agency: 'Agency name',
        dimensionattributeorder_start_date_time: start_date,
        dimensionattributeorder_end_date_time: end_date,
        dimensionorder_id: 605084194,
        dimensionline_item_name: 'Hershey test - In-Feed - :30 - iOS',
        dimensionline_item_id: 1170022354,
        dimensionattributeline_item_start_date_time: start_date,
        dimensionattributeline_item_end_date_time: end_date,
        dimensionattributeline_item_cost_type: 'CPM',
        dimensionattributeline_item_cost_per_unit: 20000000,
        dimensionattributeline_item_goal_quantity: 85000,
        dimensionattributeline_item_non_cpd_booked_revenue: 1700000000,
        columntotal_line_item_level_impressions: 85001,
        columntotal_line_item_level_clicks: 977,
        columntotal_line_item_level_ctr: 0.0115,
        columntotal_line_item_level_all_revenue: 1700020000,
        columnvideo_viewership_completion_rate: 0.5998
    )
  end

  def report_csv_cpd(opts = {})
    @_report_csv_cpd ||= generate_csv(
      build :dfp_report_cummulative_csv_data,
        dimensionorder_name: 'ioname',
        dimensionadvertiser_name: 'Advertiser name',
        dimensionattributeorder_agency: 'Agency name',
        dimensionattributeorder_start_date_time: start_date,
        dimensionattributeorder_end_date_time: end_date,
        dimensionorder_id: 605084194,
        dimensionline_item_name: 'Hershey test - In-Feed - :30 - iOS',
        dimensionline_item_id: 1170022354,
        dimensionattributeline_item_start_date_time: start_date,
        dimensionattributeline_item_end_date_time: end_date,
        dimensionattributeline_item_cost_type: 'CPD',
        dimensionattributeline_item_cost_per_unit: 20000000,
        dimensionattributeline_item_goal_quantity: 85000,
        dimensionattributeline_item_non_cpd_booked_revenue: 1700000000,
        columntotal_line_item_level_impressions: 85001,
        columntotal_line_item_level_clicks: 977,
        columntotal_line_item_level_ctr: 0.0115,
        columntotal_line_item_level_all_revenue: 1700020000,
        columnvideo_viewership_completion_rate: 0.5998
    )    
  end

  def multiline_report_csv
    list = []
    list << (build :dfp_report_cummulative_csv_data,
                   dimensionorder_id: io(start_date: start_date, end_date: end_date).external_io_number,
                   dimensionline_item_name: 'Hershey test - In-Feed - :30 - iOS',
                   dimensionline_item_id: 1170022353,
                   dimensionattributeline_item_start_date_time: start_date + 1.day,
                   dimensionattributeline_item_end_date_time: end_date - 1.day,
                   dimensionattributeline_item_cost_type: 'CPM',
                   dimensionattributeline_item_cost_per_unit: 20000000,
                   dimensionattributeline_item_goal_quantity: 85000,
                   dimensionattributeline_item_non_cpd_booked_revenue: 1700000000,
                   columntotal_line_item_level_impressions: 85001,
                   columntotal_line_item_level_clicks: 977,
                   columntotal_line_item_level_ctr: 0.0115,
                   columntotal_line_item_level_all_revenue: 1700020000)

    list << (build :dfp_report_cummulative_csv_data,
                   dimensionorder_id: io(start_date: start_date, end_date: end_date).external_io_number,
                   dimensionline_item_name: 'Hershey test - In-Feed - :30 - iOS',
                   dimensionline_item_id: 1170022354,
                   dimensionattributeline_item_start_date_time: start_date + 1.day,
                   dimensionattributeline_item_end_date_time: end_date + 1.day,
                   dimensionattributeline_item_cost_type: 'CPM',
                   dimensionattributeline_item_cost_per_unit: 20000000,
                   dimensionattributeline_item_goal_quantity: 85000,
                   dimensionattributeline_item_non_cpd_booked_revenue: 1700000000,
                   columntotal_line_item_level_impressions: 85001,
                   columntotal_line_item_level_clicks: 977,
                   columntotal_line_item_level_ctr: 0.0115,
                   columntotal_line_item_level_all_revenue: 1700020000)

    list << (build :dfp_report_cummulative_csv_data,
                   dimensionorder_id: io(start_date: start_date, end_date: end_date).external_io_number,
                   dimensionline_item_name: 'Hershey test - In-Feed - :30 - iOS',
                   dimensionline_item_id: 1170022356,
                   dimensionattributeline_item_start_date_time: start_date - 1.day,
                   dimensionattributeline_item_end_date_time: end_date,
                   dimensionattributeline_item_cost_type: 'CPM',
                   dimensionattributeline_item_cost_per_unit: 20000000,
                   dimensionattributeline_item_goal_quantity: 85000,
                   dimensionattributeline_item_non_cpd_booked_revenue: 1700000000,
                   columntotal_line_item_level_impressions: 85001,
                   columntotal_line_item_level_clicks: 977,
                   columntotal_line_item_level_ctr: 0.0115,
                   columntotal_line_item_level_all_revenue: 1700020000)

    @_multiline_report_csv ||= generate_multiline_csv(list.first.keys, list.map(&:values))
  end

  def line_item_csv
    @_line_item_csv ||= double('line_item_csv', valid?: true)
  end

  def io(opts= {})
    opts[:company_id] = company.id
    @_io = create :io, opts
  end

  def start_date
    @start_date ||= 6.months.ago.to_date
  end

  def end_date
    @end_date ||= 5.months.ago.to_date
  end
end
