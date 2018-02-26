source 'https://rubygems.org'

gem 'actionpack-action_caching'
gem 'activerecord-session_store'
#gem 'activerecord-sqlserver-adapter', git: 'https://github.com/calonso-conabio/activerecord-sqlserver-adapter.git', branch: '4-0-stable', ref: '47b6d7b'
gem 'ancestry', git: 'https://github.com/calonso-conabio/ancestry.git', :ref => 'bfadb2c'  # lee los ancestros en modo de arbol
gem 'axlsx', git: 'https://github.com/randym/axlsx.git', ref: 'c8ac844'
gem 'axlsx_rails'
gem 'blurrily', git: 'https://github.com/calonso-conabio/blurrily.git', :ref => 'c0cbbd1e9961774a6b8e2546285d38095b4d1bfa'  # forza a blurrily a usar rails 5
gem 'bootstrap-sass', '~> 3.3.6'
gem 'carrierwave'
gem 'cocoon'
gem 'coffee-rails', '~> 4.2'
gem 'composite_primary_keys'
gem 'daemons'  # para hacer ejecutables bash
gem 'delayed_job'
gem 'delayed_job_active_record'  # pone commits para correrlos en un determinado tiempo, puede ser desde consola
gem 'devise'
gem 'exifr'
gem 'fontello_rails_converter'
gem 'haml'
gem 'htmlentities'
gem 'i18n-js'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'levenshtein-ffi', :require => 'levenshtein'
gem 'mail'
gem 'mime-types'
gem 'mysql2'
gem 'nokogiri'  # hacer un parse con xml
gem 'pg'
gem 'puma', '~> 3.7'  # Use Puma as the app server
gem 'rack-contrib'
gem 'rack-google-analytics'
gem 'rails', '5.1.5'
gem 'railties'
gem 'rake'
gem 'recaptcha', :require => 'recaptcha/rails'  # con el api de google
gem 'rest-client', :require => 'rest_client'
gem 'rinku', :require => 'rails_rinku'  # extiende el metodo auto_link
gem 'roo', :require => 'roo'  # Solo lectura excel, open office, google docs
gem 'rubyXL', :require => 'rubyXL'  # Crea archivos xlsx, con formato
gem 'rubyzip', :require => 'zip'
gem 'sass-rails', '~> 5.0'
gem 'savon'  # para consumir webservices con SOAP y WSDL
gem 'seed_dump'  # extrae las tuplas de un modelo o de toda la base
gem 'soulmate', :require => 'soulmate/server'
gem 'therubyracer', platforms: :ruby
#gem 'tiny_tds', github: 'rails-sqlserver/tiny_tds'
gem 'turbolinks', '~> 5'  # hace mas rapidos los links
gem 'trollop'
gem 'uglifier', '~> 1.3.0'
gem 'wash_out'
gem 'whenever', :require => false
gem 'wicked_pdf'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
#gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]