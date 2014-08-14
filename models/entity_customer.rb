module Applyance
  class EntityCustomer < Sequel::Model

    many_to_one :entity, :class => :'Applyance::Entity'

    def self.make(params)
      entity = Entity.first(:id => params[:id])
      Stripe.api_key = Applyance::Server.settings.stripe_secret_key

      begin
        cu = Stripe::Customer.create(
          :description => "#{entity.name} [#{entity.id}]",
          :card => params['stripe_token']
        )
      rescue => e
        raise BadRequestError.new({ detail: "There was an error creating a customer with Stripe." })
      end

      card = cu.cards.data.first

      entity_customer = self.create(
        :entity_id => entity.id,
        :stripe_id => cu.id,
        :last4 => card.last4,
        :exp_month => card.exp_month,
        :exp_year => card.exp_year
      )

      entity_customer
    end

    def make_update(params)
      Stripe.api_key = Applyance::Server.settings.stripe_secret_key

      begin
        cu = Stripe::Customer.retrieve(self.stripe_id)
        cu.card = params['stripe_token']
        new_cu = cu.save
      rescue => e
        raise BadRequestError.new({ detail: "There was an error saving the customer with Stripe." })
      end

      card = new_cu.cards.data.first

      self.update(
        :last4 => card.last4,
        :exp_month => card.exp_month,
        :exp_year => card.exp_year
      )

      self
    end

  end
end
