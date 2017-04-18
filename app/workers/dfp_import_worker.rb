class DfpImportWorker < BaseWorker
  def perform
    DfpApiConfiguration.switched_on.each do |dfp_api_configuration|
      DFP::ImporterService.new(dfp_api_configuration: dfp_api_configuration).perform
    end
  end
end