source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.1'

gem 'bcrypt'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'dotenv-rails'
gem 'jwt'
gem 'pg'
gem 'puma', '~> 3.12'
gem 'rails', '~> 5.2.4.3'
gem 'pundit'
gem 'wicked_pdf'
gem 'jbuilder'
# gem 'time_tracker_extension', '~> 0.2', path: '/var/www/extension'
gem 'time_tracker_extension', '~> 0.2', git: 'https://github.com/x13enos/time_tracker_extension'
gem "skylight"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do
  gem 'better_errors'
  gem 'pry-rails'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'pundit-matchers', '~> 1.6.0'
  gem 'rspec_junit_formatter'
end

gem 'tzinfo-data', platforms: %I[mingw mswin x64_mingw jruby]
