source 'https://rubygems.org'

ruby '2.3.4'

gem 'rails', '4.2.3'
gem 'pg'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'puma'
gem 'bootstrap-sass', '~> 3.3.5'
gem 'devise'
gem 'devise_invitable', '~> 1.3.4'
gem 'knock', git: 'https://github.com/trizes/knock.git', branch: 'master'
gem 'rollbar', '~> 2.14.0'
gem 'activeadmin', '~> 1.0.0'
gem 'haml-rails', '~> 0.9'
gem 'angular-rails-templates'
gem 'inline_svg'
gem 'paranoia', '~> 2.0'
gem 'jbuilder'
gem 'chronic'
gem 'sidekiq'
gem 'sinatra', '>= 1.3.0', require: nil
gem 'clockwork'
gem 'newrelic_rpm'
gem 'awesome_print'
gem 'active_model_serializers', '= 0.8.3'
gem 'dalli'
gem 'rubyzip'
gem 'font-awesome-rails'
gem 'griddler'
gem 'griddler-sendgrid'
gem 'aws-sdk'
gem 'responders'
gem 'roar'
gem 'countries'
gem 'faraday'
gem 'attr_encrypted', '~> 3.0.0'
gem 'net-sftp', require: false
gem 'google-dfp-api'
gem 'clean_pagination'
gem 'switch_user'
gem 'oauth2'
gem 'asana'
gem 'pluck_to_hash'
gem 'upsert'
gem 'hashie'
gem 'active_record_union'
gem 'user_agent_parser'
gem 'geocoder'
gem 'rack-cors', :require => 'rack/cors'
gem 'smarter_csv'
gem 'daemons'

source 'https://rails-assets.org' do
  gem 'rails-assets-angular'
  gem 'rails-assets-angular-route'
  gem 'rails-assets-angular-bootstrap'
  gem 'rails-assets-angular-resource'
  gem 'rails-assets-angular-messages'
  gem 'rails-assets-underscore'
  gem 'rails-assets-angular-ui-select'
  gem 'rails-assets-angular-sanitize'
  gem 'rails-assets-ng-file-upload'
  gem 'rails-assets-angular-xeditable'
  gem 'rails-assets-chartjs'
  gem 'rails-assets-angular-loading-bar'
  gem 'rails-assets-angular-ui-sortable'
  gem 'rails-assets-inflection'
  gem 'rails-assets-ngInflection'
  gem 'rails-assets-ngInfiniteScroll'
  gem 'rails-assets-angular-paginate-anything'
end

group :production, :staging do
  gem 'rails_12factor'
end

group :test do
  gem 'shoulda-matchers', require: false
  gem 'vcr'
  gem 'webmock'
  gem 'simplecov', require: false
end

group :development do
  gem 'lol_dba'
  gem 'bullet'
  gem 'letter_opener'
  gem 'meta_request'
end

group :development, :test do
  gem 'rspec-rails', '~> 3.0'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'jasmine-rails'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'ffaker'
  gem 'guard-rspec', require: false
  gem 'libnotify', require: false
  gem 'fuubar'
  gem 'timecop'
  gem 'pry-rails'
  gem 'byebug'
  # code smell detector
  gem 'reek'

  gem 'capybara-webkit'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  source 'https://rails-assets.org' do
    gem 'rails-assets-angular-mocks'
  end
  gem 'test_after_commit'
end
