require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'open-uri'
require 'csv'
require File.expand_path('../config', __FILE__)
require 'blurrily/client.rb'  #para el fuzzy match

CONFIG = BuscadorConfig.new(File.expand_path('../config.yml', __FILE__))

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Buscador
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    config.autoload_paths += %W(#{config.root}/lib)

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :es
    #config.sass.preferred_syntax=:sass
  end
end

# General settings
SITE_NAME = CONFIG.site_name
SITE_NAME_SHORT = CONFIG.site_name_short || SITE_NAME
FUZZY_NOM_COM = Blurrily::Client.new(:host => '127.0.0.1', :db_name => 'nombres_comunes')
FUZZY_NOM_CIEN = Blurrily::Client.new(:host => '127.0.0.1', :db_name => 'nombres_cientificos')
