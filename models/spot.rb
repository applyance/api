module Applyance
  class Spot < Sequel::Model

    extend Applyance::Lib::Strings

    many_to_one :entity, :class => :'Applyance::Entity'

    many_to_many :blueprints, :class => :'Applyance::Blueprint'
    many_to_many :applications, :class => :'Applyance::Application'

    def validate
      super
      validates_presence :name
    end

    def after_save
      super

      # Create slug
      # Needs to be unique within the entity, that is all
      _slug = self.class.to_slug(self.name, '')
      spot_count = self.class.where(:entity_id => self.entity_id, :'_slug' => _slug).exclude(:id => self.id).count
      slug = (spot_count == 0) ? _slug : "#{_slug}-#{spot_count + 1}"
      self.this.update(:slug => slug, :'_slug' => _slug)
    end

    def get_citizens
      citizens = []
      self.applications.each { |a| citizens.concat(a.citizens) }
      citizens.uniq { |c| c.id }.sort_by { |c| c.last_activity_at }.reverse
    end

  end
end
