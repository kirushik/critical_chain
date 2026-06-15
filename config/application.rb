require File.expand_path('boot', __dir__)

# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
# require "sprockets/railtie"  # Removed - using Propshaft instead
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CriticalChain
  class Application < Rails::Application
    # Preserve the full timezone (not just the UTC offset) when calling #to_time.
    # Rails 8.0 accepts :zone or :offset here; the legacy `true` mapped to :offset
    # and now emits a deprecation. This app runs in UTC with no #to_time/#in_time_zone
    # usage, so :zone is behavior-identical. (Removed entirely once on Rails 8.1.)
    config.active_support.to_time_preserves_timezone = :zone

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure Propshaft to load assets from app/javascript in addition to app/assets
    config.assets.paths << Rails.root.join('app/javascript')
  end
end
