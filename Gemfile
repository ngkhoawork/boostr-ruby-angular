source 'https://rubygems.org'

ruby '2.2.2'

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
gem 'knock', git: 'git@github.com:trizes/knock.git', branch: 'master'
gem 'rollbar', '~> 1.5.3'
gem 'activeadmin', '~> 1.0.0.pre1'
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
gem 'money'
gem 'countries'
gem 'faraday'
gem 'attr_encrypted', '~> 3.0.0'

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
end

group :test do
  gem 'shoulda-matchers', require: false
end

group :development, :test do
  gem 'rspec-rails', '~> 3.0'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'jasmine-rails'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'ffaker'
  gem 'guard-rspec', require: false
  gem 'fuubar'
  gem 'poltergeist'
  gem 'timecop'

  # Call 'binding.pry' anywhere in the code to stop execution and get a debugger console
  gem 'pry-rails'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  source 'https://rails-assets.org' do
    gem 'rails-assets-angular-mocks'
  end
end
