require 'upsert/active_record_upsert'

class AccountProductRevenueFactService < BaseService
  def perform
    accounts.each do |client|
      time_dimensions.each do |time_dimension|
        date_range = { start_date: time_dimension.start_date, end_date: time_dimension.end_date }
        revenues = get_revenues_for_account_by_date(client.id, client.company_id, date_range)
        revenues.each do |product_id, revenue|
          find_or_create_record(client.id, time_dimension.id, client.company_id, product_id, revenue)
        end
      end
    end
  end

  # def upsert_record(account_dimension_id, time_dimension_id, company_id, product_dimension_id, revenue_amount)
  #   Upsert.batch(ActiveRecord::Base.retrieve_connection, :account_product_revenue_facts) do |batch|
  #     batch.row({ account_dimension_id: account_dimension_id,
  #                 time_dimension_id: time_dimension_id,
  #                 company_id: company_id,
  #                 product_dimension_id: product_dimension_id
  #               },
  #               { account_dimension_id: account_dimension_id,
  #                 time_dimension_id: time_dimension_id,
  #                 company_id: company_id,
  #                 product_dimension_id: product_dimension_id,
  #                 revenue_amount: revenue_amount.to_i,
  #                 created_at: DateTime.now,
  #                 updated_at: DateTime.now })
  #     end
  # end

  def get_revenues_for_account_by_date(account_id, company_id, date_range)
    AccountProductRevenueCalculationService.new(account_id: account_id, company_id: company_id, date_range: date_range).perform
  end

  def find_or_create_record(account_dimension_id, time_dimension_id, company_id, product_dimension_id, revenue_amount)
    fact = AccountProductRevenueFact.find_or_initialize_by(account_dimension_id: account_dimension_id,
                                                           time_dimension_id: time_dimension_id,
                                                           company_id: company_id,
                                                           product_dimension_id: product_dimension_id)
    if fact.persisted? && fact.revenue_amount != revenue_amount.to_i
      fact.update_attributes(revenue_amount: revenue_amount.to_i)
    else
      fact.update_attributes(revenue_amount: revenue_amount.to_i)
    end
  end

  private

  def accounts
    @accounts ||= AccountDimension.pluck_to_struct(:id, :company_id)
  end

  def time_dimensions
    @time_dimensions ||= TimeDimension.pluck_to_struct(:id, :start_date, :end_date)
  end
end