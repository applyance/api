module Applyance
  class Entity < Sequel::Model
    many_to_one :domain, :class => :'Applyance::Domain'
    one_to_many :admins, :class => :'Applyance::Admin'
    one_to_many :admin_invites, :class => :'Applyance::AdminInvite'
    one_to_many :units, :class => :'Applyance::Unit'

    # Register a new entity with the specified account
    def self.register(account, params)
      entity = self.new
      entity.update_fields(params[:entity], [:name], :missing => :skip)
      entity.save

      # Create admin
      Admin.create(
        :entity_id => entity.id,
        :account_id => account.id,
      )

      entity
    end
  end
end
