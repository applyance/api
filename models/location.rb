module Applyance
  class Location < Sequel::Model

    many_to_one :coordinate, :class => :'Applyance::Coordinate'
    many_to_one :address, :class => :'Applyance::Address'

    def self.make(params)
      location = self.new

      if params['coordinate']

        # Create coordinate
        coordinate = Coordinate.make(params['coordinate'])
        location.set(:coordinate_id => coordinate.id)

        # Create address
        results = Geocoder.search("#{coordinate.lat}, #{coordinate.lng}")
        if results.first
          address = Address.make_from_geocoded_result(results.first)
          location.set(:address_id => address.id)
        end

      elsif params['address']

        # Create address
        address = Address.make(params['address'])
        location.set(:address_id => address.id)

        # Create coordinate
        result = Geocoder.coordinates(address.to_s)
        if result
          coordinate = Coordinate.create(:lat => result[0], :lng => result[1])
          location.set(:coordinate_id => coordinate.id)
        end

      end

      location.save
      location
    end

  end
end
