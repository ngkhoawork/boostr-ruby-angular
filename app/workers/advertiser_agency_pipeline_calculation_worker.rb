class AdvertiserAgencyPipelineCalculationWorker < BaseWorker

  def perform
    companies.each do |company_id|
      time_dimensions.each do |time_dimension|
        Facts::AdvertiserAgencyPipelineFactService.perform(time_dimension: time_dimension,
                                                           company_id: company_id )
      end
    end
  end

  private

  def companies
    @_companies ||= Company.where(id: 11).pluck(:id)
  end

  def time_dimensions
    @_time_dimensions ||= TimeDimension.pluck_to_struct(:id, :start_date, :end_date)
  end
end