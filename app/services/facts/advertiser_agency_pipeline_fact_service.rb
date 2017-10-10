class Facts::AdvertiserAgencyPipelineFactService < BaseService
  def self.perform(params)
    self.new(params).tap do |instance|
      instance.find_or_create_facts
    end
  end

  def find_or_create_facts
    Facts::AccountAgencyPipelineFactCreationHandler.perform(calculated_facts: calculated_pipelines,
                                                            time_dimension: time_dimension,
                                                            company_id: company_id)
  end

  private

  def calculated_pipelines
    pipeline_service.calculated_pipelines
  end

  def pipeline_service
    Facts::AdvertiserAgencyPipelineCalculationService.perform(company_id: company_id,
                                                              start_date: time_dimension.start_date,
                                                              end_date: time_dimension.end_date)
  end

  def time_dimension
    @_time_dimension ||= TimeDimension.find(time_dimension_id)
  end
end