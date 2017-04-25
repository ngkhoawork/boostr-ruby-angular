class DFP::MonthlyReportImportService < BaseService
  def perform
    perform_monthly_import
  end

  private

  def perform_monthly_import
    return make_monthly_import unless check_date_match
    make_monthly_import if monthly_query.monthly_recurrence_day == current_day_of_month_value
  end

  def make_monthly_import
    return unless get_report_file
    DFP::MonthlyImportService.new(
        dfp_api_configuration.company_id,
        'dfp_monthly',
        report_file: get_report_file
    ).perform
    File.delete(report_file_path)
  end

  def current_day_of_month_value
    current_day.day
  end

  def current_day
    DateTime.current.in_time_zone('Pacific Time (US & Canada)')
  end

  def get_report_file
    file_url = get_report_link
    return unless file_url
    file = open(file_url)
    IO.copy_stream(file, report_file_path)
    report_file_path
  end

  def report_file_path
    @report_file_name ||= './tmp/' + DateTime.now.to_s + '_monthly_report.csv'
  end

  def get_report_link
    dfp_reports_service.generate_report_by_saved_query(monthly_query.report_id)
  end

  def monthly_query
    dfp_api_configuration.dfp_report_queries.monthly.last
  end

  def dfp_reports_service
    @dfp_reports_service ||= DFP::ReportsService.new(credentials:  dfp_api_configuration.json_api_key,
                                                     network_code: dfp_api_configuration.network_code,
                                                     company_id:   dfp_api_configuration.company_id,
                                                     dfp_query_type: 'monthly')
  end
end
