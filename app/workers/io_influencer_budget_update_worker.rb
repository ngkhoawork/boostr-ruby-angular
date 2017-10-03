class IoInfluencerBudgetUpdateWorker < BaseWorker
  def perform(io_ids)
    Io.where(id: io_ids).each do |io|
    	io.update_influencer_budget
    end
  end
end