module Applyance
  class Entity < Sequel::Model

    include Applyance::Lib::Attachments
    include Applyance::Lib::Locations
    extend Applyance::Lib::Strings

    many_to_one :domain, :class => :'Applyance::Domain'
    many_to_one :logo, :class => :'Applyance::Attachment'
    many_to_one :location, :class => :'Applyance::Location'
    many_to_one :parent, :class => :'Applyance::Entity'

    one_to_many :reviewers, :class => :'Applyance::Reviewer'
    one_to_many :reviewer_invites, :class => :'Applyance::ReviewerInvite'
    one_to_many :entities, :class => :'Applyance::Entity', :key => :parent_id

    one_to_many :spots, :class => :'Applyance::Spot'
    one_to_many :templates, :class => :'Applyance::Template'
    one_to_many :pipelines, :class => :'Applyance::Pipeline'
    one_to_many :labels, :class => :'Applyance::Label'

    many_to_many :definitions, :class => :'Applyance::Definition'
    many_to_many :blueprints, :class => :'Applyance::Blueprint'
    many_to_many :applications, :class => :'Applyance::Application'

    def validate
      super
      validates_presence :name
      validates_unique :slug
    end

    def before_validation
      super

      # Create slug
      self._slug = self.class.to_slug(self.name, '')
      entity_count = self.class.where(:'_slug' => self._slug).exclude(:id => self.id).count
      self.slug = (entity_count == 0) ? self._slug : "#{self._slug}-#{entity_count + 1}"
    end

    def after_create
      super

      # After creation of a new entity, grab all the parent reviewers
      # and assign them to this entity
      return if self.parent.nil?

      self.parent.reviewers.each do |reviewer|
        Reviewer.create(
          :entity_id => self.id,
          :account_id => reviewer.account_id,
          :scope => reviewer.scope
        )
      end
    end

  end
end
