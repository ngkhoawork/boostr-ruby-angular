class AccountProductPipelineFactService < BaseService
  def perform
    clients.each do |client|
      service = AccountProductTotalAmountCalculationService.new(client: client)
      service.perform
      total_amounts = service.calculated_amounts
      total_amounts.each do |total_amount_item|
        fact_item = AccountProductPipelineFact.find_or_initialize_by(company_id: client.company.id,
                                                                     account_dimension_id: client.id,
                                                                     time_dimension_id: total_amount_item.time_dimension_id,
                                                                     product_id: total_amount_item.product_id)
        fact_item.weighted_amount = total_amount_item.weighted_amount
        fact_item.unweighted_amount = total_amount_item.unweighted_amount
        fact_item.save
      end
    end
  end

  private

  def clients
    @clients ||= Client.all
  end

  def time_dimensions
    @time_dimensions ||= TimeDimension.all
  end
end