module Applyance
  class ReviewerInvite < Sequel::Model

    include Applyance::Lib::Tokens

    many_to_one :unit, :class => :'Applyance::Unit'

    def validate
      super
      validates_presence [:email, :access_level]
      validates_unique :email
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
      reviewer = Reviewer.create(
        :unit_id => self.unit_id,
        :account_id => account.id,
        :access_level => self.access_level)

      reviewer
    end

  end
end
