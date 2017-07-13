class AccountProductPipelineFactService < BaseService
  def perform
    clients.each do |client|
      time_dimensions.each do |time_dimension|
        service = AccountProductTotalAmountCalculationService.new(client: client, time_dimension: time_dimension)
        calculated_amounts = service.perform
        Upsert.batch(ActiveRecord::Base.retrieve_connection, :account_product_pipeline_facts) do |batch|
          calculated_amounts.each do |calculated_amount|
            batch.row({ account_dimension_id: client.id,
                        time_dimension_id: time_dimension.id,
                        company_id: client.company_id,
                        product_dimension_id: calculated_amount['product_id']},
                      { account_dimension_id: client.id,
                        time_dimension_id: time_dimension.id,
                        company_id: client.company_id,
                        product_dimension_id: calculated_amount['product_id'],
                        weighted_amount: calculated_amount['weighted_budget'].to_i,
                        unweighted_amount: calculated_amount['unweighted_budget'].to_i,
                        created_at: DateTime.now,
                        updated_at: DateTime.now
                      })
          end
        end
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