class Facts::AccountProductRevenueFactService < BaseService
  def perform
    accounts.each do |client|
      time_dimensions.each do |time_dimension|
        date_range = { start_date: time_dimension.start_date, end_date: time_dimension.end_date }
        revenue_service = Facts::AccountProductRevenueCalculationService.new(account_id: client.id, company_id: client.company_id, date_range: date_range)
        revenue_service.remove_unused_records
        revenues = revenue_service.calculate_revenues
        revenues.each do |product_id, revenue|
          find_or_create_record(client.id, time_dimension.id, client.company_id, product_id, revenue)
        end
      end
    end
  end

  private

  def find_or_create_record(account_dimension_id, time_dimension_id, company_id, product_dimension_id, revenue_amount)
    fact = AccountProductRevenueFact.find_or_initialize_by(account_dimension_id: account_dimension_id,
                                                           time_dimension_id: time_dimension_id,
                                                           company_id: company_id,
                                                           product_dimension_id: product_dimension_id)
    if fact.persisted? && fact.revenue_amount != revenue_amount.to_i
      fact.update_attributes(revenue_amount: revenue_amount.to_i)
    elsif fact.new_record?
      fact.update_attributes(revenue_amount: revenue_amount.to_i)
    end
  end

  def accounts
    @accounts ||= AccountDimension.where(company_id: 11).pluck_to_struct(:id, :company_id)
  end

  def time_dimensions
    @time_dimensions ||= TimeDimension.pluck_to_struct(:id, :start_date, :end_date)
  end
end