module Applyance
  class Rating < Sequel::Model
    many_to_one :application, :class => :'Applyance::Application'
    many_to_one :account, :class => :'Applyance::Account'

    def validate
      super
      validates_unique([:application_id, :account_id])
    end
  end
end
