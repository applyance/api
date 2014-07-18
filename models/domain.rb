module Applyance
  class Domain < Sequel::Model
    one_to_many :entities, :class => :'Applyance::Entity'
    one_to_many :definitions, :class => :'Applyance::Definition'
  end
end
