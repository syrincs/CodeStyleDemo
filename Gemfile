source 'https://rubygems.org'

# core
gem 'rails', '~>4.1.4'
gem 'turbolinks'
gem 'jquery-turbolinks'
gem 'activerecord-session_store'

gem 'simple_form', '~>3.1.0.rc2'
# gem 'simple_form', :git => "https://github.com/plataformatec/simple_form.git", :branch => "bootstrap-3"

gem 'attrtastic'
gem 'dynamic_form'
gem 'navigasmic'
gem 'will_paginate'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'premailer-rails'
gem 'font-awesome-rails', '~> 4.5.0'
gem 'angularjs-rails'
gem 'active_attr'
gem 'state_machine'
gem 'geoip'

# database
gem 'ancestry'
gem 'activerecord-import'

# validators
gem "email_validator"
gem "date_validator"
gem "validate_url"

# authentication
# gem 'omniauth'

# authorization
gem 'cancan'

# assets & views pipeline
gem 'json'
gem 'slim'
gem 'swfobject-rails'
gem 'jsonify-rails'
gem 'coffee-views'
gem 'bootstrap-sass', '~> 3.1.0'
gem 'select2-rails'
gem 'bourbon'

# file uploads
gem 'carrierwave'
gem 'mini_magick'
gem 'remotipart'

gem 'plupload-rails'
# gem 'plupload-rails', :path => "~/Coding/projects/Opensource/ruby/plupload-rails"

# internationalization
gem 'rails-i18n'
gem 'i18n_screwdriver'

# misc
gem 'bcrypt-ruby'
gem 'money'
gem 'whenever'
gem 'nokogiri'
gem "sanitize", "~>2.1.0"
gem "htmlentities", ">=4.1.0"
gem 'sidekiq'

# needed by sidekiq web frontend
gem 'sinatra', :require => false

gem 'awesome_print'
gem 'autoprefixer-rails'

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'sprite-factory'
  gem 'chunky_png'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'database_cleaner'
  gem 'blueprints'
  gem 'launchy'
  gem 'email_spec'
  gem 'capistrano', '~>2.13.5'
  gem 'capistrano-ext'
  gem 'better_errors'
  gem 'letter_opener'
end

group :test do
  gem 'webmock'
  gem 'capybara', '~> 1.1.4'
  # gem 'capybara-webkit'
  gem 'timecop'
  gem "factory_girl_rails"
  gem 'simplecov', :require => false
  gem 'simplecov-rcov', :require => false
end

group :staging, :production do
  gem 'exception_notification'
end

platforms :ruby do
  gem 'pg'

  group :development, :test do
    gem 'thin'
    gem 'binding_of_caller'
  end

  group :assets do
    gem 'therubyracer', :require => 'v8'
    gem 'libv8'
  end

  group :staging, :production do
    gem 'unicorn'
  end
end

platforms :jruby do
  gem 'activerecord-jdbcpostgresql-adapter'

  group :assets do
    gem 'therubyrhino'
  end
end
