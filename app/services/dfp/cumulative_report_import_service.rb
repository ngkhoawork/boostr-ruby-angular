class DFP::CumulativeReportImportService < BaseService

  def perform
    perform_cumulative_import
  end

  private

  def perform_cumulative_import
    return make_cumulative_import unless check_date_match
    return make_cumulative_import if cumulative_query.is_daily_recurrent?
    make_cumulative_import if cumulative_query.weekly_recurrence_day == current_day_name
  end

  def make_cumulative_import
    return unless get_report_file
    DFP::CumulativeImportService.new(
        dfp_api_configuration.company_id,
        'dfp_cumulative',
        report_file: get_report_file
    ).perform
    File.delete(report_file_path)
  end

  def current_day_name
    current_day.strftime('%A')
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
    @report_file_name ||= './tmp/' + DateTime.now.to_s + '_cumulative_report.csv'
  end

  def get_report_link
    @report_link ||= dfp_reports_service.generate_report_by_saved_query(cumulative_query.report_id)
  end

  def cumulative_query
    dfp_api_configuration.dfp_report_queries.cumulative.last
  end

  def dfp_reports_service
    @dfp_reports_service ||= DFP::ReportsService.new(credentials:  dfp_api_configuration.json_api_key,
                                                     network_code: dfp_api_configuration.network_code,
                                                     company_id:   dfp_api_configuration.company_id,
                                                     dfp_query_type: 'cumulative')
  end
end
