source 'https://rubygems.org'

ruby '2.5.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.1'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 6.0'

gem 'puma'

gem 'bootstrap-sass'
gem 'autoprefixer-rails'
gem 'font-awesome-sass', '~> 4.7'

gem 'page_title_helper'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
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
gem 'sdoc', '~> 1.0.0', group: :doc

gem 'annotate', group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
group :production do
  gem 'pg', '~> 0.21'
  gem 'rails_12factor'
  gem 'rack-ssl', require: 'rack/ssl'
  gem 'thin'
end

group :development, :test do
  gem 'spring'
  gem 'spring-commands-rspec'

  gem 'pry-rails'
  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'sqlite3'

  gem 'rspec-rails', '>= 4.0.0.beta3'

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
  gem 'apparition'

  gem 'database_cleaner'

  gem 'guard-rspec'
  gem 'libnotify'

  gem 'rspec_junit_formatter', :git => 'git@github.com:circleci/rspec_junit_formatter.git'

  gem 'simplecov', require: false
  gem "codeclimate-test-reporter", require: false
end

# To provide authentication
gem 'devise'
# To auth with Google
gem 'omniauth-google-oauth2'
# To enable privilege separation
gem 'pundit'

# Heroku-friendly configuration management
gem 'figaro'

gem 'draper'
