module Applyance
  class SpotDefinition < Sequel::Model
    many_to_one :spot, :class => :'Applyance::Spot'
    many_to_one :definition, :class => :'Applyance::Definition'
  end
end
