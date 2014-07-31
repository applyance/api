module Applyance
  class Pipeline < Sequel::Model
    many_to_one :entity, :class => :'Applyance::Entity'
    one_to_many :stages, :class => :'Applyance::Stage'
  end
end
