require_relative '_protection'
require_relative '_errors'
require_relative 'attachments'
require_relative 'domains'
require_relative 'roles'
require_relative 'accounts'
require_relative 'entities'
require_relative 'entity_customers'
require_relative 'citizens'
require_relative 'profiles'
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
require_relative 'threads'

module Applyance
  module Routing
    module Init
      def self.registered(app)
        app.extend(Applyance::Routing::Protection)

        app.register Applyance::Routing::Errors
        app.register Applyance::Routing::Attachments
        app.register Applyance::Routing::Domains
        app.register Applyance::Routing::Roles
        app.register Applyance::Routing::Accounts
        app.register Applyance::Routing::Entities
        app.register Applyance::Routing::EntityCustomers
        app.register Applyance::Routing::Citizens
        app.register Applyance::Routing::Profiles
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
        app.register Applyance::Routing::Threads
      end
    end
  end
end
