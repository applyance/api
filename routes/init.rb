require_relative 'errors'
require_relative 'roles'
require_relative 'accounts'
require_relative 'entities'

module Applyance
  module Routing
    module Init
      def self.registered(app)
        app.register Applyance::Routing::Errors
        app.register Applyance::Routing::Roles
        app.register Applyance::Routing::Accounts
        app.register Applyance::Routing::Entities
      end
    end
  end
end
