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

        # Require models, can't go at the top because it requires a
        # Sequel connection
        require_relative 'account'
        require_relative 'entity'

      end
    end
  end
end
