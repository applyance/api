module Applyance
  module Lib
    module Locations

      def locate(params, property = :location)
        return if params.nil?

        location = Location.make(params)
        self.send("#{property.to_s}_id=", location.id)
        self.save
        
        location
      end

    end
  end
end
