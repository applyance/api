require_relative 'errors'
require_relative 'attachments'
require_relative 'domains'
require_relative 'roles'
require_relative 'accounts'
require_relative 'entities'
require_relative 'admins'
require_relative 'admin_invites'
require_relative 'units'
require_relative 'reviewers'
require_relative 'reviewer_invites'

module Applyance
  module Routing
    module Init
      def self.registered(app)
        app.register Applyance::Routing::Errors
        app.register Applyance::Routing::Attachments
        app.register Applyance::Routing::Domains
        app.register Applyance::Routing::Roles
        app.register Applyance::Routing::Accounts
        app.register Applyance::Routing::Entities
        app.register Applyance::Routing::Admins
        app.register Applyance::Routing::AdminInvites
        app.register Applyance::Routing::Units
        app.register Applyance::Routing::Reviewers
        app.register Applyance::Routing::ReviewerInvites
      end
    end
  end
end
