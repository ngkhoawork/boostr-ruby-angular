class DFP::ImporterService < BaseService
  def perform
    perform_cumulative_import
    perform_monthly_import
  end

  private

  def perform_cumulative_import
    return make_cumulative_import if cumulative_query.is_daily_recurrent?
    make_cumulative_import if cumulative_query.weekly_recurrence_day == current_day_name
  end

  def perform_monthly_import
    make_monthly_import if monthly_query.monthly_recurrence_day == current_day_of_month_value
  end

  def current_day_name
    current_day.strftime("%A")
  end

  def current_day_of_month_value
    current_day.day
  end

  def current_day
    DateTime.current
  end

  def make_cumulative_import
    DFP::CumulativeImportService.new(dfp_api_configuration.company_id, report_file: get_cumulative_report_file).perform
  end

  def make_monthly_import
    #TODO: Implement after Ostap's changes
  end

  def get_cumulative_report_file
    dfp_reports_service.generate_report_by_saved_query(cumulative_query.report_id)
  end

  def get_monthly_report_file
    dfp_reports_service.generate_report_by_saved_query(monthly_query.report_id)
  end

  def cumulative_query
    dfp_api_configuration.dfp_report_queries.cumulative.last
  end

  def monthly_query
    dfp_api_configuration.dfp_report_queries.monthly.last
  end

  def dfp_reports_service
    @dfp_reports_service ||= DFP::ReportsService.new(credentials:  dfp_api_configuration.json_api_key,
                                                     network_code: dfp_api_configuration.network_code,
                                                     company_id:   dfp_api_configuration.company_id)
  end


end