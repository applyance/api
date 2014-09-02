module Applyance
  class Definition < Sequel::Model

    extend Applyance::Lib::Strings

    plugin :serialization, :json, :helper

    one_to_many :datums, :class => :'Applyance::Datum'
    one_to_many :blueprints, :class => :'Applyance::Blueprint'
    one_through_one :domain, :class => :'Applyance::Domain'
    one_through_one :entity, :class => :'Applyance::Entity'

    dataset_module do
      def by_first_created
        order(:created_at)
      end
      def by_latest_created
        reverse_order(:created_at)
      end
    end

    def before_validation
      super
      self.slug = self.class.to_slug(self.label)
    end

    def validate
      super
      validates_presence [:label, :type, :name]
      validates_unique :slug
    end

    # Create a definition from a submitted field
    def self.make_from_field_for_spots(field, spots)

      # See if a definition exists for that label
      slug = to_slug(field[:definition][:label])
      definition = Definition.first(:slug => slug)

      if definition.nil?

        # Create definition
        definition = Definition.create(
          :name => field[:definition][:name],
          :label => field[:definition][:label],
          :description => field[:definition][:description],
          :type => field[:definition][:type],
          :helper => field[:definition][:helper]
        )

        # Add definitions to entity
        entities = spots.map { |s| s.entity }
        entities.uniq { |e| e.id }.each do |entity|
          entity.add_definition(definition)
          entity.save
        end

      end

      definition
    end

  end
end
