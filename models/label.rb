module Applyance
  class Label < Sequel::Model
    many_to_one :entity, :class => :'Applyance::Entity'
  end
end
