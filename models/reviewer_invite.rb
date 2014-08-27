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

      template = {
        :template => File.join('reviewer_invites', 'claim'),
        :locals => {
          :entity => self.entity,
          :claim_digest => self.claim_digest
        }
      }
      message = {
        :subject => "Claim Your Invite",
        :to => [ { :email => self.email } ],
        :merge_vars => [{
          "rcpt" => self.email,
          "vars" => [{ "content" => "there", "name" => "name" }]
        }]
      }
      Applyance::Lib::Emails::Sender::send_template(template, message)

    end

  end
end
