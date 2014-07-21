module Applyance
  class Admin < Sequel::Model
    many_to_one :entity, :class => :'Applyance::Entity'
    many_to_one :account, :class => :'Applyance::Account'

    def after_create
      super

      # Make sure entity admins are full-access reviewers for
      # all sub units
      self.entity.units.each do |unit|
        Reviewer.make_from_admin(unit, self)
      end
    end
  end
end
