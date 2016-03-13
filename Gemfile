source 'https://rubygems.org'

gem 'rails', '4.2.5'
gem 'rake', '10.4.2'
gem 'pg', '0.17.1'
gem 'xeroizer', :git => 'git://github.com/waynerobinson/xeroizer.git'
gem 'redis'
gem 'monadic'
gem 'aasm'
gem 'httplog'

# Job scheduling
gem 'sidekiq'
gem 'sinatra', :require => nil
gem 'clockwork'
gem 'sidekiq-unique-jobs'

group :development do
  gem 'better_errors'
  gem 'guard-bundler'
  gem 'guard-rails'
  gem 'guard-rspec'
end
group :development, :test do
  gem 'spring'
  gem 'dotenv-rails'
  gem 'hirb'
  gem 'awesome_print'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
end
group :test do
  gem 'vcr'
  gem 'webmock'
  gem 'fakeredis'
  gem 'factory_girl'
  gem 'spy'
end
