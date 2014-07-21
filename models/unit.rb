module Applyance
  class Unit < Sequel::Model
    many_to_one :entity, :class => :'Applyance::Entity'
    one_to_many :reviewers, :class => :'Applyance::Reviewer'
    one_to_many :reviewer_invites, :class => :'Applyance::ReviewerInvite'
    one_to_many :spots, :class => :'Applyance::Spot'
    one_to_many :templates, :class => :'Applyance::Template'
    one_to_many :pipelines, :class => :'Applyance::Pipeline'
    one_to_many :labels, :class => :'Applyance::Label'
    one_to_many :definitions, :class => :'Applyance::Definition'
    many_to_many :blueprints, :class => :'Applyance::Blueprint'

    def validate
      super
      validates_presence [:name]
    end

    def after_create
      super

      # Make sure entity admins are full-access reviewers for
      # this new unit
      self.entity.admins.each do |admin|
        Reviewer.make_from_admin(self, admin)
      end
    end

  end
end
