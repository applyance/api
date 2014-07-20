module Applyance
  class AdminInvite < Sequel::Model

    include Applyance::Lib::Tokens

    many_to_one :entity, :class => :'Applyance::Entity'

    def validate
      super
      validates_presence [:email]
      validates_unique :email
    end

    def after_create
      super
      # TODO: Send email to new admin
    end

    def self.make(entity, params)
      admin_invite = self.new
      admin_invite.set_fields(params, [:email], :missing => :skip)
      admin_invite.set(:entity_id => entity.id)
      admin_invite.set_token(:claim_digest)
      admin_invite.save
      admin_invite
    end

    def claim(params)
      self.update(:status => "claimed")

      # Create account and verify it
      account = Account.first(:email => self.email)
      if account.nil?
        account = Account.make("admin", params)
      elsif !account.has_role?("admin")
        account.add_role(Role.first(:name => "admin"))
      end
      account.update(:is_verified => true)

      # Create admin
      admin = Admin.find_or_create(
        :entity_id => self.entity_id,
        :account_id => account.id)

      # Initialize as reviewer for each unit
      self.entity.units.each do |unit|
        Reviewer.make_from_admin(unit, admin)
      end
    end

  end
end
