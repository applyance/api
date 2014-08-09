module Applyance
  class Rating < Sequel::Model
    many_to_one :citizen, :class => :'Applyance::Citizen'
    many_to_one :account, :class => :'Applyance::Account'

    def validate
      super
      validates_unique([:citizen_id, :account_id])
    end
  end
end
