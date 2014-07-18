module Applyance
  class Spot < Sequel::Model
    many_to_one :unit, :class => :'Applyance::Unit'
    one_to_many :ratings, :class => :'Applyance::Rating'
    one_to_many :definitions, :class => :'Applyance::SpotDefinition'
  end
end
