
require_relative 'boot'
require 'rails/all'
require 'uri'
require 'open-uri'
require 'csv'
require File.expand_path('../config', __FILE__)

CONFIG = BuscadorConfig.new(File.expand_path('../config.yml', __FILE__))

# DelayedJob priorities
USER_PRIORITY = 0
NOTIFICATION_PRIORITY = 1
USER_INTEGRITY_PRIORITY = 2
INTEGRITY_PRIORITY = 3
OPTIONAL_PRIORITY = 4

Bundler.require(*Rails.groups)

# General settings
IP = CONFIG.site_url.split(':')[1].gsub('//', '')
PORT = CONFIG.site_url.split(':')[2][0..-1]
SITE_NAME = CONFIG.site_name
SITE_NAME_SHORT = CONFIG.site_name_short || SITE_NAME

require 'blurrily/client.rb'

BLURRILY_HOST = ENV.fetch('BLURRILY_HOST', '127.0.0.1')

FUZZY_NOM_COM = Blurrily::Client.new(
  host: BLURRILY_HOST,
  db_name: 'nombres_comunes'
)

FUZZY_NOM_CIEN = Blurrily::Client.new(
  host: BLURRILY_HOST,
  db_name: 'nombres_cientificos'
)

module Buscador
  class Application < Rails::Application

    config.assets.precompile << 'delayed/web/application.css'

    config.load_defaults 5.1

    Encoding.default_external = Encoding::UTF_8
    Encoding.default_internal = Encoding::UTF_8

    config.time_zone = 'Mexico City'

    config.middleware.use I18n::JS::Middleware

    # Librerías heredadas
    config.autoload_paths << "#{config.root}/lib"
    config.eager_load_paths += Dir[Rails.root.join('lib')]

    # Modelos heredados que utilizan constantes de nivel superior.
    rutas_modelos_legacy = Dir[
      Rails.root.join('app', 'models', '*/')
    ].reject do |ruta|
      %w[admin api fichas geoportal pmc].include?(File.basename(ruta))
    end

    config.autoload_paths.concat(rutas_modelos_legacy)

    # Compatibilidad de los modelos administrativos con Zeitwerk.
    #
    # app/models/admin/catalogos/catalogo.rb
    #   => Admin::Catalogo
    #
    # app/models/admin/catalogos/especie_catalogo.rb
    #   => Admin::EspecieCatalogo
    #
    # La carpeta catalogos es organizativa y no forma
    # parte del namespace de las clases.
    initializer 'buscador.zeitwerk_admin_catalogos',
                before: :setup_main_autoloader do

      Rails.autoloaders.main.collapse(
        Rails.root.join('app/models/admin/catalogos').to_s
      )
    end

    # Cambia el nombre de la tabla por defecto
    ActiveRecord::SessionStore::Session.table_name = 'sessions'

    # Devise
    config.action_mailer.default_url_options = {
      host: CONFIG.site_url
    }

    # Evitar escape innecesario de caracteres como "&"
    config.active_support.escape_html_entities_in_json = false

    # Configuración de correo
    Mail.defaults do
      retriever_method(
        :imap,
        {
          address: CONFIG.smtp.address,
          user_name: CONFIG.smtp.user_name,
          password: CONFIG.smtp.password
        }
      )

      delivery_method(
        :smtp,
        address: CONFIG.smtp.address,
        user_name: CONFIG.smtp.user_name,
        password: CONFIG.smtp.password
      )
    end

  end
end
