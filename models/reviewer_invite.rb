module Applyance
  class ReviewerInvite < Sequel::Model

    include Applyance::Lib::Tokens

    many_to_one :entity, :class => :'Applyance::Entity'

    def validate
      super
      validates_presence [:email, :scope]
      validates_unique([:email, :entity_id])
    end

    def self.make(entity, params)
      invite = self.new
      invite.set_fields(params, ['email', 'scope'], :missing => :skip)
      invite.set(:entity_id => entity.id)
      invite.set_token(:claim_digest)
      invite.save
      invite
    end

    def claim(params)
      self.update(:status => "claimed")

      # Create account and verify it
      account = Account.make("reviewer", params.merge({ 'email' => self.email }))
      account.update(:is_verified => true)

      # Create reviewer
      reviewer = Reviewer.find_or_create(
        :entity_id => self.entity_id,
        :account_id => account.id)
      reviewer.update(:scope => self.scope)

      reviewer
    end

    # Allow reviewer to claim account
    def send_claim_email
      return if Applyance::Server.test?
      m = Mandrill::API.new(Applyance::Server.settings.mandrill_api_key)
      message = {
        :subject => "Claim Your Invite",
        :from_name => "The Team at Applyance",
        :text => "Hello,\n\nYou've been invited to manage #{self.entity.name}. Please claim your account by visiting this link: #{Applyance::Server.settings.client_url}/reviewers/claim?code=#{self.claim_digest}.\n\nThanks,\n\nThe Team at Applyance",
        :to => [ { :email => self.email } ],
        :from_email => "contact@applyance.co"
      }
      sending = m.messages.send(message)
    end

  end
end
