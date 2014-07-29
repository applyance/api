module Applyance
  class AdminInvite < Sequel::Model

    include Applyance::Lib::Tokens

    many_to_one :entity, :class => :'Applyance::Entity'

    def validate
      super
      validates_presence [:email, :access_level]
    end

    def after_create
      super
      # TODO: Send email to new admin
    end

    def self.make(entity, params)
      admin_invite = self.new
      admin_invite.set_fields(params, ['email', 'access_level'], :missing => :skip)
      admin_invite.set(:entity_id => entity.id)
      admin_invite.set_token(:claim_digest)
      admin_invite.save
      admin_invite
    end

    def claim(params)
      self.update(:status => "claimed")

      # Create account and verify it
      account = Account.make("admin", params.merge({ 'email' => self.email }))
      account.update(:is_verified => true)

      # Create admin
      admin = Admin.find_or_create(
        :entity_id => self.entity_id,
        :account_id => account.id)
      admin.update(:access_level => self.access_level)

      # Initialize as reviewer for each unit
      self.entity.units.each do |unit|
        Reviewer.make_from_admin(unit, admin)
      end

      admin
    end

    # Allow admin to claim account
    def send_claim_email
      return if Applyance::Server.test?
      m = Mandrill::API.new(Applyance::Server.settings.mandrill_api_key)
      message = {
        :subject => "Claim Your Invite",
        :from_name => "The Team at Applyance",
        :text => "Hello,\n\nYou've been invited to manage #{self.entity.name}. Please claim your account by visiting this link: #{Applyance::Server.settings.client_url}/admins/claim?code=#{self.claim_digest}.\n\nThanks,\n\nThe Team at Applyance",
        :to => [ { :email => self.email } ],
        :from_email => "contact@applyance.co"
      }
      sending = m.messages.send(message)
    end

  end
end
