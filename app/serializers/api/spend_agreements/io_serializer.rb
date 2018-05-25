class Api::SpendAgreements::IoSerializer < ActiveModel::Serializer
  attributes(
      :id,
      :name,
      :advertiser_name,
      :advertiser_id,
      :start_date,
      :end_date,
      :agreement_amt,
      :budget
  )

  private

  def agreement_amt
    Calculators::Agreements::IoInPeriodBudgetService.new(agreement_start_date: @options[:agreement_start_date],
                                                         agreement_end_date: @options[:agreement_end_date],
                                                         io_id: object.id).perform
  end

  def advertiser_name
    object.advertiser.name
  end
end
