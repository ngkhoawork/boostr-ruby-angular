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
    return unless get_cumulative_report_file
    DFP::CumulativeImportService.new(
        dfp_api_configuration.company_id,
        'dfp_cumulative',
        report_file: get_cumulative_report_file
    ).perform
  end

  def current_day_name
    current_day.strftime('%A')
  end

  def current_day
    DateTime.current.in_time_zone('Pacific Time (US & Canada)')
  end

  def get_cumulative_report_file
    dfp_reports_service.generate_report_by_saved_query(cumulative_query.report_id)
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
