require 'sinatra/base'
require 'sinatra/config_file'
require 'sequel'

require 'active_support/inflector'
require 'bcrypt'
require 'rabl'
require 'sidekiq'

require 'mandrill'
require 'aws-sdk'

require_relative 'lib/_init'
require_relative 'helpers/_init'
require_relative 'models/_init'
require_relative 'routes/_init'

module Applyance
  class Server < Sinatra::Base

    # Load config file
    register Sinatra::ConfigFile
    config_file 'config.yml'

    # Config
    set :root, File.dirname(__FILE__)
    enable :logging

    configure :development, :test do
      set :show_exceptions, :after_handler
    end

    # Register RABL for easy APIs
    Rabl.register!
    Rabl.configure do |config|
      config.include_json_root = false
      config.include_child_root = false
    end

    # Helpers
    helpers Applyance::Helpers::Security
    helpers Applyance::Helpers::Media

    # Models
    register Applyance::Modeling::Init

    # Routing
    register Applyance::Routing::Init

  end
end
