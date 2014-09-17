module Applyance
  module Routing
    module Webhooks

      def self.registered(app)

        app.post '/webhooks/stripe', :provides => [:json] do
          Stripe.api_key = Applyance::Server.settings.stripe_secret_key

          event_json = JSON.parse(request.body.read)
          event = Stripe::Event.retrieve(event_json["id"])

          puts "Handling webhook from Stripe with type, [#{event.type}]"
          puts "  ==  "
          puts event.inspect
          puts "  ==  "

          case event.type
          when "customer.subscription.updated"
            puts "  Handling a subscription update from Stripe."
            event.data.object
          when "invoice.created"
            puts "  Handling an invoice creation from Stripe."

          else
            puts "  Unknown event type from Stripe."
          end

          status 200
        end

      end
    end
  end
end
