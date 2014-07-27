module Applyance
  class Location < Sequel::Model

    many_to_one :coordinate, :class => :'Applyance::Coordinate'
    many_to_one :address, :class => :'Applyance::Address'

    def self.make(params)
      location = self.new
      coordinate = Coordinate.make(params['coordinate'])
      location.set(:coordinate_id => coordinate.id)
      location.save
      location
    end

  end
end
