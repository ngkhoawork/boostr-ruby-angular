require 'sidekiq'
require 'sidekiq/web'

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [(ENV['SIDEKIQ_USER'] || 'support@boostrcrm.com'), (ENV['SIDEKIQ_PASSWORD'] || 'losgatos')]
end

Sidekiq::Cron::Job.create(name: 'Detect Stopped PMPs', cron: '0 0 0 * *', class: 'StoppedPmpDetectWorker')
