require_relative '_errors'
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
require_relative 'spots'
require_relative 'definitions'
require_relative 'blueprints'
require_relative 'datums'
require_relative 'fields'
require_relative 'applications'
require_relative 'pipelines'
require_relative 'stages'
require_relative 'labels'
require_relative 'segments'
require_relative 'ratings'
require_relative 'notes'

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
        app.register Applyance::Routing::Spots
        app.register Applyance::Routing::Definitions
        app.register Applyance::Routing::Blueprints
        app.register Applyance::Routing::Datums
        app.register Applyance::Routing::Fields
        app.register Applyance::Routing::Applications
        app.register Applyance::Routing::Pipelines
        app.register Applyance::Routing::Stages
        app.register Applyance::Routing::Labels
        app.register Applyance::Routing::Segments
        app.register Applyance::Routing::Ratings
        app.register Applyance::Routing::Notes
      end
    end
  end
end
