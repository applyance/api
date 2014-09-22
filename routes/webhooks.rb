module Applyance
  module Routing
    module Webhooks

      def self.registered(app)

        app.post '/webhooks/stripe', :provides => [:json] do

          event_json = JSON.parse(request.body.read)
          error 500 unless event_json["id"]

          Stripe.api_key = Applyance::Server.settings.stripe_secret_key
          if Applyance::Server.test?
            event = Stripe::Event.construct_from(event_json)
          else
            event = Stripe::Event.retrieve(event_json["id"])
          end

          puts "Handling webhook from Stripe [#{event.type}, #{event.id}]."

          case event.type
          when "customer.card.updated"
            card = event.data.object
            customer_id = card.customer

            puts "  Handling a card update from Stripe for customer [#{customer_id}]"

            entity_customer = EntityCustomer.first(:stripe_id => customer_id)
            entity_customer.set_card_from_stripe(card)
            entity_customer.save

          when "customer.card.deleted"
            card = event.data.object
            customer_id = card.customer

            puts "  Handling a card delete from Stripe for customer [#{customer_id}]"

            entity_customer = EntityCustomer.first(:stripe_id => customer_id)
            entity_customer.delete_card
            entity_customer.save

          when "customer.subscription.created"
            subscription = event.data.object
            customer_id = subscription.customer
            plan = subscription.plan

            puts "  Handling a subscription created from Stripe for customer [#{customer_id}]."

            # Add the new subscription to the entity customer
            entity_plan = EntityCustomerPlan.first(:stripe_id => plan.id)
            entity_customer = EntityCustomer.first(:stripe_id => customer_id)
            entity_customer.set(:plan_id => entity_plan.id)
            entity_customer.set_subscription_from_stripe(subscription)
            entity_customer.save

          when "customer.subscription.updated"
            subscription = event.data.object
            customer_id = subscription.customer
            plan = subscription.plan

            puts "  Handling a subscription update from Stripe for customer [#{customer_id}]."

            entity_plan = EntityCustomerPlan.first(:stripe_id => plan.id)
            entity_customer = EntityCustomer.first(:stripe_subscription_id => subscription.id)
            entity_customer.set(:plan_id => entity_plan.id)
            entity_customer.set_subscription_from_stripe(subscription)
            entity_customer.save

            # If a subscription has been updated and the status is unpaid or canceled,
            # then let's knock the plan down to the free plan

            if ["unpaid", "canceled"].include?(subscription.status)
              puts "  Unpaid or canceled subscription."
              puts "  Switch from the current plan to the free plan."

              entity_customer.entity.get_admins.each { |r| r.send_subscription_canceled_email(entity_customer) }

              unless Applyance::Server.test?
                stripe_customer = Stripe::Customer.retrieve(customer_id)
                stripe_subscription = stripe_customer.subscriptions.retrieve(subscription.id)
                stripe_subscription.plan = "free"
                stripe_subscription.save
              end
            end

          when "customer.subscription.deleted"
            subscription = event.data.object
            customer_id = subscription.customer
            plan = subscription.plan

            puts "  Handling a subscription deletion from Stripe for customer [#{customer_id}]."
            puts "  This means we need to set the customer back to the free plan."

            free_plan = EntityCustomerPlan.first(:stripe_id => "free")
            entity_customer = EntityCustomer.first(:stripe_subscription_id => subscription.id)
            entity_customer.update(
              :subscription_status => "active",
              :plan_id => free_plan.id)

          when "invoice.created"
            invoice = event.data.object
            customer_id = invoice.customer
            puts "  Handling an invoice created from Stripe for customer [#{customer_id}]."

            # Create a new invoice for the entity customer
            entity_customer = EntityCustomer.first(:stripe_id => customer_id)
            EntityCustomerInvoice
              .create(:customer_id => entity_customer.id)
              .update_from_stripe(invoice)

          when "invoice.updated"
            invoice = event.data.object
            puts "  Invoice [#{invoice.id}] updated."

            # Update the customer invoice from stripe
            EntityCustomerInvoice
              .first(:stripe_invoice_id => invoice.id)
              .update_from_stripe(invoice)

          when "invoice.payment_succeeded"
            invoice = event.data.object
            puts "  Payment succeeded for invoice [#{invoice.id}]"

            # Send payment receipt email if there is an amount due
            if invoice.amount_due > 0
              entity_invoice = EntityCustomerInvoice.first(:stripe_invoice_id => invoice.id)
              entity_invoice.customer.entity.get_admins.each { |r| r.send_payment_receipt_email(entity_invoice) }
              puts "    Receipt email sent."
            else
              puts "    Not sending receipt email because the amount was $0."
            end

          when "invoice.payment_failed"
            invoice = event.data.object
            customer_id = invoice.customer
            puts "  Payment failed for invoice [#{invoice.id}]"
            puts "  Subscription will be updated and set to free plain if this continues."

          when "customer.subscription.trial_will_end"
            subscription = event.data.object
            customer_id = subscription.customer
            puts "  Subscription trial is ending in 3 days for [#{customer_id}]."

            # Send an email to entity admins letting them know their
            # trial will end in 3 days
            entity_customer = EntityCustomer.first(:stripe_id => customer_id)
            entity_customer.entity.get_admins.each { |r| r.send_trial_will_end_email }

          else
            puts "  Unhandled event type from Stripe."
          end

          status 200
        end

      end
    end
  end
end
