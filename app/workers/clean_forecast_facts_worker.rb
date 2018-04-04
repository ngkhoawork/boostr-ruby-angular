class CleanForecastFactsWorker < BaseWorker
  def perform
    clean(ForecastPipelineFact)
    clean(ForecastRevenueFact)
    clean(ForecastPmpRevenueFact)
  end

  private

  def clean(relation)
    relation.zero_amount.select(:id).find_in_batches(batch_size: 1000) do |ids|
      relation.where(id: ids).delete_all
    end
  end
end