require 'upsert/active_record_upsert'

class AccountProductRevenueFactService < BaseService
  def perform
    accounts.each do |client|
      time_dimensions.each do |time_dimension|
        date_range = { start_date: time_dimension.start_date, end_date: time_dimension.end_date }
        service = AccountProductRevenueCalculationService.new(company_id: client.company_id, date_range: date_range)
        revenues = service.perform
        Upsert.batch(ActiveRecord::Base.retrieve_connection, :account_product_revenue_facts) do |batch|
          revenues.each do |product_id, revenue_amount|
            batch.row({ account_dimension_id: client.id,
                        time_dimension_id: time_dimension.id,
                        company_id: client.company_id,
                        product_dimension_id: product_id
                      },
                      { account_dimension_id: client.id,
                        time_dimension_id: time_dimension.id,
                        company_id: client.company_id,
                        product_dimension_id: product_id,
                        revenue_amount: revenue_amount.to_i,
                        created_at: DateTime.now,
                        updated_at: DateTime.now })
          end
        end
      end
    end
  end

  private

  def accounts
    @clients ||= Client.includes(:company)
  end

  def time_dimensions
    @time_dimensions ||= TimeDimension.all
  end
end