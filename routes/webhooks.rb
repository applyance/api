module Applyance
  module Routing
    module Webhooks

      def self.registered(app)

        app.post '/webhooks/stripe', :provides => [:json] do
          status 200
        end

      end
    end
  end
end
