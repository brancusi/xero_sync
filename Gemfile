source 'https://rubygems.org'

gem 'rails', '4.2.4'
gem 'rake', '10.4.2'
gem 'pg', '0.17.1'
gem "xeroizer", :git => 'git://github.com/waynerobinson/xeroizer.git'
gem 'sidekiq'
gem 'sinatra', '>= 1.3.0', :require => nil
gem 'redis'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_21]
  gem 'guard-bundler'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'rb-fchange', :require=>false
  gem 'rb-fsevent', :require=>false
  gem 'rb-inotify', :require=>false
  gem 'hirb'
  gem 'awesome_print'
  gem 'interactive_editor'
  gem 'rack-mini-profiler'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'http_logger'
end
group :development, :test do
  gem 'spring'
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'dotenv-rails'
  gem 'gist'
end
group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'faker'
  gem 'launchy'
end
