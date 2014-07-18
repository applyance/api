module Applyance
  class Admin < Sequel::Model
    many_to_one :entity, :class => :'Applyance::Entity'
    many_to_one :account, :class => :'Applyance::Account'
  end
end
