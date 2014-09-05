module Applyance
  class Domain < Sequel::Model

    plugin :sluggable, :source => :name

    one_to_many :entities, :class => :'Applyance::Entity'
    many_to_many :definitions, :class => :'Applyance::Definition'

    def validate
      super
      validates_presence :name
      validates_unique :name, :slug
    end

  end
end
