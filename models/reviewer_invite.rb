module Applyance
  class ReviewerInvite < Sequel::Model

    include Applyance::Lib::Tokens

    many_to_one :unit, :class => :'Applyance::Unit'

    def validate
      super
      validates_presence [:email]
      validates_unique :email
    end

    def after_create
      super
      # TODO: Send email to new reviewer
    end

    def self.make(unit, params)
      admin_invite = self.new
      admin_invite.set_fields(params, [:email, :access_level], :missing => :skip)
      admin_invite.set(:unit_id => unit.id)
      admin_invite.set_token(:claim_digest)
      admin_invite.save
      admin_invite
    end

    def claim(params)
      self.update(:status => "claimed")

      # Create account and verify it
      account = Account.first(:email => self.email)
      if account.nil?
        account = Account.make("reviewer", params)
      elsif !account.has_role?("reviewer")
        account.add_role(Role.first(:name => "reviewer"))
      end
      account.update(:is_verified => true)

      # Create reviewer
      reviewer = Reviewer.create(
        :unit_id => self.unit_id,
        :account_id => account.id,
        :access_level => self.access_level)
    end

  end
end
