module Applyance
  class Address < Sequel::Model

    one_to_many :locations, :class => :'Applyance::Location'

    def self.make(address)
      results = Geocoder.search(address)
      self.make_from_geocoded_result(results.first)
    end

    def self.make_from_geocoded_result(result)
      address = self.new
      address.address_1 = result.street_address
      address.city = result.city
      address.state = result.state_code
      address.postal_code = result.postal_code
      address.country = result.country_code
      address.save
      address
    end

    def to_s
      "#{address_1} #{address_2}, #{city}, #{state} #{postal_code} #{country}"
    end

  end
end
