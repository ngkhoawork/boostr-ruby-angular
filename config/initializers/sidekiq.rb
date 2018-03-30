require 'sidekiq'
require 'sidekiq/web'
require 'sidekiq-status'

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [(ENV['SIDEKIQ_USER'] || 'support@boostrcrm.com'), (ENV['SIDEKIQ_PASSWORD'] || 'losgatos')]
end

Sidekiq.configure_client do |config|
  Sidekiq::Status.configure_client_middleware config, expiration: 30.minutes
end

Sidekiq.configure_server do |config|
  Sidekiq::Status.configure_server_middleware config, expiration: 30.minutes

  Sidekiq::Status.configure_client_middleware config, expiration: 30.minutes
end
