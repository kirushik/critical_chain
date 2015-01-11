source 'https://rubygems.org'

ruby '2.1.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

gem 'bootstrap-sass'
gem 'autoprefixer-rails'
gem 'font-awesome-sass'

gem 'page_title_helper'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'annotate', group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
group :production do
  gem 'pg'
  gem 'rails_12factor'
  gem 'rack-ssl', require: 'rack/ssl'
  gem 'thin'
end

group :development, :test do
  gem 'spring'

  gem 'pry-rails'
  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'sqlite3'

  gem 'rspec-rails'

  gem 'factory_girl_rails'
  gem 'faker'

  gem 'guard-migrate'
end

group :development do
  gem 'guard-livereload', require: false
  gem 'rack-livereload'
end

group :test do
  gem 'capybara'
  gem 'poltergeist'

  gem 'database_cleaner'
  
  gem 'guard-rspec'
  gem 'libnotify'

  gem 'rspec_junit_formatter', :git => 'git@github.com:circleci/rspec_junit_formatter.git'
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