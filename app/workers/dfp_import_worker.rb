class DfpImportWorker < BaseWorker
  def perform
    DfpApiConfiguration.switched_on.each do |dfp_api_configuration|
      DFP::CumulativeReportImportService.new(dfp_api_configuration: dfp_api_configuration, check_date_match: true).perform
      DFP::MonthlyReportImportService.new(dfp_api_configuration: dfp_api_configuration, check_date_match: true).perform
    end
  end
end