module Applyance
  class Address < Sequel::Model

    one_to_many :locations, :class => :'Applyance::Location'

  end
end
