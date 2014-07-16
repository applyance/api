require 'sinatra/base'
require 'sinatra/config_file'
require 'sequel'
require 'rabl'

require_relative 'models/init'
require_relative 'routes/init'
require_relative 'lib/errors'

module Applyance
  class App < Sinatra::Base

    # Load config file
    register Sinatra::ConfigFile
    config_file 'config.yml'

    # Config
    set :root, File.dirname(__FILE__)
    enable :logging

    configure :development do
      set :show_exceptions, :after_handler
    end

    # Register RABL for easy APIs
    Rabl.register!
    Rabl.configure do |config|
      config.include_json_root = false
    end

    #
    # Basic API Key Authentication
    # Authorization takes place in the controller action. This authenticates
    # based on the authorization header and loads the proper account.
    #
    # e.g.
    # protected!(lambda { |account| account.pk == params[:id].to_i })
    #
    helpers do
      def ensure_xhr!
        error 401 unless request.xhr?
      end
      def ensure_not_xhr!
        error 401 if request.xhr?
      end
      def protected!(fn)
        error 401 unless request.env['HTTP_AUTHORIZATION']
        api_key = request.env['HTTP_AUTHORIZATION'].split('auth=')[1]
        account = Account.first(:api_key => api_key)
        error 401 unless fn.call(account)
        account
      end
    end

    # Register app stuff
    register Applyance::Modeling::Init
    register Applyance::Routing::Init

  end
end
