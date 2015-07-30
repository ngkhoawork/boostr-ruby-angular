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
gem 'rollbar', '~> 1.5.3'
gem 'activeadmin', '~> 1.0.0.pre1'
gem 'haml-rails', '~> 0.9'
gem 'angular-rails-templates'
gem 'inline_svg'
gem 'paranoia', '~> 2.0'

source 'https://rails-assets.org' do
  gem 'rails-assets-angular'
  gem 'rails-assets-angular-route'
  gem 'rails-assets-angular-bootstrap'
  gem 'rails-assets-angular-resource'
  gem 'rails-assets-underscore'
  gem 'rails-assets-angular-ui-select'
  gem 'rails-assets-angular-sanitize'
  gem 'rails-assets-ng-file-upload'
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

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  source 'https://rails-assets.org' do
    gem 'rails-assets-angular-mocks'
  end
end
