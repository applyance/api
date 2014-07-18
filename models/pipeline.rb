module Applyance
  class Pipeline < Sequel::Model
    many_to_one :unit, :class => :'Applyance::Unit'
    one_to_many :stages, :class => :'Applyance::Stage'
  end
end
