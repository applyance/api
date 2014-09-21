module Applyance
  class EntityCustomer < Sequel::Model

    many_to_one :entity, :class => :'Applyance::Entity'
    many_to_one :plan, :class => :'Applyance::EntityCustomerPlan'
    one_to_many :invoices, :class => :'Applyance::EntityCustomerInvoice', :key => :customer_id

    def self.init(entity)

      plan = EntityCustomerPlan.first(:stripe_id => "premium")
      stripe_customer_hash = {
        :description => "#{entity.name} [#{entity.id}]",
        :plan => plan.stripe_id
      }
      entity_customer = EntityCustomer.new(
        :entity_id => entity.id,
        :plan_id => plan.id
      )

      Stripe.api_key = Applyance::Server.settings.stripe_secret_key
      begin
        cu = Stripe::Customer.create(stripe_customer_hash)
      rescue => e
        raise BadRequestError.new({ detail: "There was an error creating a customer with Stripe." })
      end
      entity_customer.set(:stripe_id => cu.id)
      entity_customer.set_subscription_from_stripe(cu.subscriptions.data.first)

      entity_customer.save
      entity_customer
    end

    def self.make(params)

      entity = Entity.first(:id => params[:id])
      plan = EntityCustomerPlan.first(:stripe_id => "premium")
      stripe_hash = {
        :description => "#{entity.name} [#{entity.id}]",
        :plan => plan.stripe_id
      }
      if params['stripe_token']
        stripe_hash[:card] = params['stripe_token']
      end
      entity_customer = EntityCustomer.new(
        :entity_id => entity.id,
        :plan_id => plan.id
      )

      Stripe.api_key = Applyance::Server.settings.stripe_secret_key
      begin
        cu = Stripe::Customer.create(stripe_hash)
      rescue => e
        raise BadRequestError.new({ detail: "There was an error creating a customer with Stripe." })
      end
      entity_customer.set(:stripe_id => cu.id)
      entity_customer.set_subscription_from_stripe(cu.subscriptions.data.first)
      if params['stripe_token']
        entity_customer.set_subscription_from_stripe(cu.cards.data.first)
      end

      entity_customer.save
      entity_customer
    end

    def make_update(params)
      self.update_card(params)
      self.update_plan(params)
      self
    end

    def update_card(params)
      return unless params['stripe_token']

      Stripe.api_key = Applyance::Server.settings.stripe_secret_key
      begin
        cu = Stripe::Customer.retrieve(self.stripe_id)
        cu.card = params['stripe_token']
        new_cu = cu.save
      rescue => e
        raise BadRequestError.new({ detail: "There was an error saving the card with Stripe." })
      end
      self.set_card_from_stripe(new_cu.cards.data.first)

      self.save
      self
    end

    def update_plan(params)
      return unless params['plan']

      Stripe.api_key = Applyance::Server.settings.stripe_secret_key

      plan = EntityCustomerPlan.first(:stripe_id => params['plan'])
      return if plan.nil?

      location_count = self.entity.root_entity.total_child_count
      quantity = [location_count, 1].max

      begin
        customer = Stripe::Customer.retrieve(self.stripe_id)
        subscription = customer.subscriptions.retrieve(self.stripe_subscription_id)
        subscription.plan = plan.stripe_id
        subscription.quantity = quantity
        new_su = subscription.save
      rescue => e
        puts "  Error [#{e.inspect}]"
        raise BadRequestError.new({ detail: "There was an error saving the subscription with Stripe." })
      end

      self.set(:plan_id => plan.id)
      self.set_subscription_from_stripe(new_su)
      self.save

      self
    end

    def update_quantity
      Stripe.api_key = Applyance::Server.settings.stripe_secret_key

      location_count = self.entity.root_entity.total_child_count
      quantity = [location_count, 1].max

      begin
        customer = Stripe::Customer.retrieve(self.stripe_id)
        subscription = customer.subscriptions.retrieve(self.stripe_subscription_id)
        subscription.quantity = quantity
        new_su = subscription.save
      rescue => e
        raise BadRequestError.new({ detail: "There was an error saving the subscription with Stripe." })
      end

      self.set_subscription_from_stripe(new_su)
      self.save

      self
    end

    def set_subscription_from_stripe(subscription)
      self.set(
        :subscription_status => subscription.status,
        :stripe_subscription_id => subscription.id,
        :active_until => Time.at(subscription.current_period_end).utc.to_datetime
      )
    end

    def set_card_from_stripe(card)
      self.set(
        :last4 => card.last4,
        :exp_month => card.exp_month,
        :exp_year => card.exp_year
      )
    end

    def set_from_stripe(customer)
      self.set_subscription_from_stripe(customer.subscriptions.data.first)
      self.set_card_from_stripe(customer.cards.data.first)
    end

    def delete_card
      self.set(
        :last4 => nil,
        :exp_month => nil,
        :exp_year => nil
      )
    end

  end
end
