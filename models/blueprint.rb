module Applyance
  class Blueprint < Sequel::Model
    many_to_one :definition, :class => :'Applyance::Definition'
    one_through_one :spot, :class => :'Applyance::Spot'
    one_through_one :unit, :class => :'Applyance::Unit'
    one_through_one :entity, :class => :'Applyance::Entity'
  end
end
