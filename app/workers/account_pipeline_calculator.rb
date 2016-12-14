class AccountPipelineCalculator
  include Sidekiq::Worker

  sidekiq_options queue: "default"
  sidekiq_options retry: false

  def perform()
    companies = Company.all

  end
end