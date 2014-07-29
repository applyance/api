module Applyance
  class ReviewerInvite < Sequel::Model

    include Applyance::Lib::Tokens

    many_to_one :unit, :class => :'Applyance::Unit'

    def validate
      super
      validates_presence [:email, :access_level]
      validates_unique([:email, :unit_id])
    end

    def after_create
      super
      # TODO: Send email to new reviewer
    end

    def self.make(unit, params)
      reviewer_invite = self.new
      reviewer_invite.set_fields(params, ['email', 'access_level'], :missing => :skip)
      reviewer_invite.set(:unit_id => unit.id)
      reviewer_invite.set_token(:claim_digest)
      reviewer_invite.save
      reviewer_invite
    end

    def claim(params)
      self.update(:status => "claimed")

      # Create account and verify it
      account = Account.make("reviewer", params.merge({ 'email' => self.email }))
      account.update(:is_verified => true)

      # Create reviewer
      reviewer = Reviewer.find_or_create(
        :unit_id => self.unit_id,
        :account_id => account.id
      )
      reviewer.update(:access_level => self.access_level)

      reviewer
    end

    # Allow reviewer to claim account
    def send_claim_email
      return if Applyance::Server.test?
      m = Mandrill::API.new(Applyance::Server.settings.mandrill_api_key)
      message = {
        :subject => "Claim Your Invite",
        :from_name => "The Team at Applyance",
        :text => "Hello,\n\nYou've been invited to be a reviewer at #{self.unit.name}. Please claim your account by visiting this link: #{Applyance::Server.settings.client_url}/reviewers/claim?code=#{self.claim_digest}.\n\nThanks,\n\nThe Team at Applyance",
        :to => [ { :email => self.email } ],
        :from_email => "contact@applyance.co"
      }
      sending = m.messages.send(message)
    end

  end
end
