class CleanForecastFactsWorker < BaseWorker
  def perform
    clean_pipeline_facts
    clean_revenue_facts
    clean_pmp_revenue_facts
  end

  def clean_pipeline_facts
    facts = ForecastPipelineFact.where(amount: 0)
    facts.select(:id).find_in_batches(batch_size: 1000) do |ids|
      ForecastPipelineFact.where(id: ids).delete_all
    end
  end

  def clean_revenue_facts
    facts = ForecastRevenueFact.where(amount: 0)
    facts.select(:id).find_in_batches(batch_size: 1000) do |ids|
      ForecastRevenueFact.where(id: ids).delete_all
    end
  end

  def clean_pmp_revenue_facts
    facts = ForecastPmpRevenueFact.where(amount: 0)
    facts.select(:id).find_in_batches(batch_size: 1000) do |ids|
      ForecastPmpRevenueFact.where(id: ids).delete_all
    end
  end
end