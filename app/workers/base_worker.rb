class BaseWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'default'
  sidekiq_options retry: false
end
