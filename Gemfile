source 'https://rubygems.org'

ruby '3.3.6'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.2.3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 6.0'

gem 'puma'

gem 'bootstrap', '~>4.6.2'
gem 'autoprefixer-rails'
gem 'font-awesome-sass', '~> 6.7'

gem 'page_title_helper'

# Use Terser as compressor for JavaScript assets
gem 'terser'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'

# In-place editing for Bootstrap and Rails
gem 'x-editable-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
#gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 2.6.5', group: :doc

gem 'annotate', group: :development

# Security scanning tools
gem 'brakeman', group: :development, require: false
gem 'bundler-audit', group: :development, require: false

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
group :production do
  gem 'pg'
  gem 'thin'
end

group :development, :test do
  gem 'pry-rails'
  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'sqlite3'

  gem 'rspec-rails', '>= 4.0.0.beta3'
  gem 'rails-controller-testing'

  gem 'factory_bot_rails'
  gem 'faker'

  gem 'guard-migrate'
end

group :development do
  gem 'guard-livereload', require: false
  gem 'rack-livereload'

  gem 'foreman'
end

group :test do
  gem 'capybara'

  # Since https://github.com/twalpole/apparition/pull/79 is not released to Rubygems
  gem 'apparition', github: 'twalpole/apparition'

  gem 'database_cleaner'

  gem 'guard-rspec'
  gem 'libnotify'

  gem 'rspec_junit_formatter'

  gem 'simplecov', require: false
  gem "codeclimate-test-reporter", require: false
end

# To provide authentication
gem 'devise'
# To auth with Google
gem 'omniauth-google-oauth2'
# In Omniauth2, we need to use POST to navigate to Google's authorization route,
# which triggers CSRF protection failures without this gem
# See also: https://github.com/omniauth/omniauth/wiki/Upgrading-to-2.0#rails
gem 'omniauth-rails_csrf_protection'

# Temporary fix till Devise Omniauth version detection is fixed upstream
# https://github.com/heartcombo/devise/issues/5326
gem 'omniauth', '~>2.1.2'

# To enable privilege separation
gem 'pundit'

# Environment variable configuration management
gem 'figaro'

gem 'draper'
