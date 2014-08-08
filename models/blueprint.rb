module Applyance
  class Blueprint < Sequel::Model
    many_to_one :definition, :class => :'Applyance::Definition'
    one_through_one :spot, :class => :'Applyance::Spot'
    one_through_one :entity, :class => :'Applyance::Entity'

    def after_create
      super

      # Go through child entities and spots, deleting the same blueprints if they exist
      self.entity.entities.each do |entity|
        entity.blueprints_dataset.where(:definition_id => self.definition_id).delete
        entity.spots.each do |spot|
          spot.blueprints_dataset.where(:definition_id => self.definition_id).delete
        end
      end
      self.entity.spots.each do |entity|
        spot.blueprints_dataset.where(:definition_id => self.definition_id).delete
      end
    end
  end
end
