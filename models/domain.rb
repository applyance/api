module Applyance
  class Domain < Sequel::Model
    one_to_many :entities, :class => :'Applyance::Entity'
    one_to_many :definitions, :class => :'Applyance::Definition'

    def validate
      super
      validates_presence :name
      validates_unique :name
    end
  end
end
