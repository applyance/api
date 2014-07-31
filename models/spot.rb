module Applyance
  class Spot < Sequel::Model
    many_to_one :entity, :class => :'Applyance::Entity'
    
    many_to_many :blueprints, :class => :'Applyance::Blueprint'
    many_to_many :applications, :class => :'Applyance::Application'

    def validate
      super
      validates_presence :name
    end
  end
end
