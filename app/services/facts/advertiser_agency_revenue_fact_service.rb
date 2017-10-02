class Facts::AdvertiserAgencyRevenueFactService < BaseService
  def self.perform(params)
    self.new(params).tap do |instance|
      instance.find_or_create_facts
    end
  end

  def find_or_create_facts
    Facts::AccountAgencyRevenueFactCreationHandler.perform(calculated_facts: calculated_revenues,
                                                           time_dimension: time_dimension)
  end

  private

  def calculated_revenues
    revenue_service.calculated_revenues
  end

  def revenue_service
    Facts::AdvertiserAgencyRevenueCalculationService.perform(company_id: company_id,
                                                             start_date: time_dimension.start_date,
                                                             end_date: time_dimension.end_date)
  end

  def time_dimension
    @_time_dimension ||= TimeDimension.find(time_dimension_id)
  end

end