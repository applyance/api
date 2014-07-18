module Applyance
  class Field < Sequel::Model
    many_to_one :application, :class => :'Applyance::Application'
    many_to_one :definition, :class => :'Applyance::Definition'
    many_to_one :answer, :class => :'Applyance::Answer'
  end
end
