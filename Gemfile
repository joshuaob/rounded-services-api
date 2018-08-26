source 'https://rubygems.org'

ruby "2.5.1"

gem 'pg', '~> 1.0'
gem 'sequel', '~> 5.11'
gem 'sinatra', '~> 2.0', '>= 2.0.3'
gem 'sinatra-contrib', '~> 2.0', '>= 2.0.3'
gem 'rake', '~> 12.3', '>= 12.3.1'
gem 'puma', '~> 3.12'
gem 'sentry-raven', '~> 2.7', '>= 2.7.4'
gem 'dotenv', '~> 2.5'
gem 'jsonapi-serializers', '~> 1.0', '>= 1.0.1'
gem 'jwt', '~> 2.1'
gem 'stripe', '~> 3.21'
gem 'capistrano', '~> 3.11'
gem 'capistrano-bundler', '~> 1.3'
gem 'capistrano3-puma', '~> 3.1', '>= 3.1.1'
gem 'capistrano-rake', '~> 0.2.0'
gem 'capistrano-rbenv', '~> 2.1', '>= 2.1.3'

group :test do
  gem 'rspec', '~> 3.8'
  gem 'factory_bot', '~> 4.11'
end

group :development, :test do
  gem 'pry', '~> 0.11.3'
end

group :development do
  gem 'guard-rspec', '~> 4.7', '>= 4.7.3', require: false
end
