module Applyance
  module Modeling
    module Init
      def self.registered(app)

        # Connect to Database
        db = Sequel.connect(
          :adapter => 'postgres',
          :database => app.settings.database_name,
          :user => app.settings.database_user,
          :password => app.settings.database_password,
          :host => app.settings.database_host,
          :loggers => [Logger.new($stdout)]
        )
        app.set :db, db

        # Load plugins
        Sequel::Model.plugin(:timestamps)
        Sequel::Model.plugin(:dirty)
        Sequel::Model.plugin(:validation_helpers)

        # Require models, can't go at the top because it requires a
        # Sequel connection
        require_relative 'error'
        require_relative 'coordinate'
        require_relative 'address'
        require_relative 'location'
        require_relative 'attachment'
        require_relative 'domain'
        require_relative 'role'
        require_relative 'account'
        require_relative 'applicant'
        require_relative 'entity'
        require_relative 'reviewer'
        require_relative 'reviewer_invite'
        require_relative 'spot'
        require_relative 'template'
        require_relative 'pipeline'
        require_relative 'stage'
        require_relative 'label'
        require_relative 'segment'
        require_relative 'application'
        require_relative 'application_activity'
        require_relative 'thread'
        require_relative 'message'
        require_relative 'note'
        require_relative 'rating'
        require_relative 'definition'
        require_relative 'blueprint'
        require_relative 'datum'
        require_relative 'field'

      end
    end
  end
end
