module Applyance
  class Coordinate < Sequel::Model
    def self.make(params)
      coordinate = self.new
      coordinate.set_fields(params, [:lat, :lng], :missing => :skip)
      coordinate.save
      coordinate
    end
  end
end
