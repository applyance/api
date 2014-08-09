module Applyance
  class Blueprint < Sequel::Model
    many_to_one :definition, :class => :'Applyance::Definition'
    one_through_one :spot, :class => :'Applyance::Spot'
    one_through_one :entity, :class => :'Applyance::Entity'

    # Go through child entities and spots, deleting the same blueprints if they exist
    def ensure_unique_in_chain
      self.entity.entities.each do |entity|
        entity.blueprints_dataset.first(:definition_id => self.definition_id).destroy
        entity.spots.each do |spot|
          spot.blueprints_dataset.first(:definition_id => self.definition_id).destroy
        end
      end
      self.entity.spots.each do |spot|
        spot.blueprints_dataset.first(:definition_id => self.definition_id).destroy
      end
    end

  end
end
