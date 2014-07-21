module Applyance
  class Definition < Sequel::Model

    extend Applyance::Lib::Strings

    plugin :serialization, :json, :helper

    one_to_many :datums, :class => :'Applyance::Datum'
    one_to_many :blueprints, :class => :'Applyance::Blueprint'
    one_through_one :domain, :class => :'Applyance::Domain'
    one_through_one :unit, :class => :'Applyance::Unit'

    def before_validation
      super
      self.name = self.class.to_slug(self.label)
    end

    def validate
      super
      validates_presence [:label, :type]
    end

    # Create a definition from a submitted field
    def self.make_from_field_for_spots(field, spots)

      # See if a definition exists for that label
      name = to_slug(field[:definition][:label])
      definition = Definition.first(:name => name)

      if definition.nil?

        # Create definition
        definition = Definition.create(
          :label => field[:definition][:label],
          :description => field[:definition][:description],
          :type => field[:definition][:type],
          :helper => field[:definition][:helper]
        )

        # Add definitions to unit
        units = spots.map { |s| s.unit }
        units.uniq { |u| u.id }.each do |unit|
          unit.add_definition(definition)
          unit.save
        end

      end

      definition
    end

  end
end
