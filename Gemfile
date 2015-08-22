source 'https://rubygems.org'

ruby '2.2.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.0'

gem 'autoprefixer-rails'
gem "font-awesome-rails"

gem 'page_title_helper'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem "pure-css-rails"
gem 'vanilla-ujs', github: 'kirushik/vanilla-ujs', branch: 'json'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

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
  gem 'spring-commands-rspec'

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
