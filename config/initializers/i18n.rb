# tell the I18n library where to find your translations
I18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}')]
I18n.load_path += Dir[Rails.root.join('config', 'locales', 'extra', '*.{rb,yml}')]
I18N_SUPPORTED_LOCALES = Dir[Rails.root.join('config', 'locales', '*.{rb,yml}')].map{|p| p[/\/([\w\-]+?)\.yml/, 1]}.compact.uniq

# set default locale to something other than :en
#I18n.default_locale = CONFIG.default_locale.to_sym if CONFIG.default_locale
I18n.default_locale = 'es'
# set up fallbacks
require 'i18n/backend/fallbacks'
I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)

# from and to locales for the translate gem (translation ui)
Rails.application.config.from_locales = [:en, :es]
Rails.application.config.to_locales = [:es, :es_cientifico]
