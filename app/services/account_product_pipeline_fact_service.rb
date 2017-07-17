class AccountProductPipelineFactService < BaseService
  def perform
    accounts.each do |account|
      time_dimensions.each do |time_dimension|
        date_range = { start_date: time_dimension.start_date, end_date: time_dimension.end_date }
        calculated_amounts = get_pipelines_for_company_by_date(account.id, account.company_id, date_range)
        calculated_amounts.each do |calculated_amount|
          find_or_create_record(account.id,
                                time_dimension.id,
                                account.company_id,
                                calculated_amount['product_id'],
                                calculated_amount['weighted_budget'],
                                calculated_amount['unweighted_budget'])
        end
      end
    end
  end

  private

  def get_pipelines_for_company_by_date(account_id, company_id, date_range)
    AccountProductTotalAmountCalculationService.new(account_id: account_id, company_id: company_id, date_range: date_range).perform
  end

  def find_or_create_record(account_dimension_id, time_dimension_id, company_id, product_dimension_id, weighted_amount, unweighted_amount)
    fact = AccountProductPipelineFact.find_or_initialize_by(account_dimension_id: account_dimension_id,
                                                            time_dimension_id: time_dimension_id,
                                                            company_id: company_id,
                                                            product_dimension_id: product_dimension_id)
    if fact.persisted? && fact.unweighted_amount != unweighted_amount.to_i
      fact.update_attributes(unweighted_amount: unweighted_amount.to_i, weighted_amount: weighted_amount.to_i)
    elsif fact.new_record?
      fact.update_attributes(unweighted_amount: unweighted_amount.to_i, weighted_amount: weighted_amount.to_i)
    end
  end

  def accounts
    @accounts ||= AccountDimension.where(company_id: 11).pluck_to_struct(:id, :company_id)
  end

  def time_dimensions
    @time_dimensions ||= TimeDimension.pluck_to_struct(:id, :start_date, :end_date)
  end
end