class ManualDfpImportWorker < BaseWorker
  def perform(api_configuration_id, report_type)
    dfp_api_configuration = ApiConfiguration.find(api_configuration_id)
    case report_type
      when 'monthly'
        DFP::MonthlyReportImportService.new(dfp_api_configuration: dfp_api_configuration, check_date_match: false).perform
      when 'cumulative'
        DFP::CumulativeReportImportService.new(dfp_api_configuration: dfp_api_configuration, check_date_match: false).perform
      else
        return
    end
  end
end