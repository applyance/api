module Applyance
  class Spot < Sequel::Model
    many_to_one :unit, :class => :'Applyance::Unit'
    one_to_many :ratings, :class => :'Applyance::Rating'
    many_to_many :blueprints, :class => :'Applyance::Blueprint'

    def validate
      super
      validates_presence :name
    end
  end
end
