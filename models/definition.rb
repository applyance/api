module Applyance
  class Definition < Sequel::Model
    many_to_one :domain, :class => :'Applyance::Domain'
    many_to_one :unit, :class => :'Applyance::Unit'
    one_to_many :spot_definitions, :class => :'Applyance::SpotDefinition'
    one_to_many :answers, :class => :'Applyance::Answer'
    one_to_many :fields, :class => :'Applyance::Field'
  end
end
