workers Integer(ENV['WEB_CONCURRENCY'] || 1)
worker_timeout 45

threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

restart_command 'puma'

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

if ENV['RACK_ENV'] == 'development'
  worker_timeout 3600
end

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end