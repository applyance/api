module Applyance
  class Coordinate < Sequel::Model

    one_to_many :locations, :class => :'Applyance::Location'

    def self.make(params)
      coordinate = self.new
      coordinate.set_fields(params, ['lat', 'lng'], :missing => :skip)
      coordinate.save
      coordinate
    end
  end
end
