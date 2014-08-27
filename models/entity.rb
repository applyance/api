module Applyance
  class Entity < Sequel::Model

    include Applyance::Lib::Attachments
    include Applyance::Lib::Locations
    extend Applyance::Lib::Strings

    one_to_one :customer, :class => :'Applyance::EntityCustomer'

    many_to_one :domain, :class => :'Applyance::Domain'
    many_to_one :logo, :class => :'Applyance::Attachment'
    many_to_one :location, :class => :'Applyance::Location'
    many_to_one :parent, :class => :'Applyance::Entity'

    one_to_many :reviewers, :class => :'Applyance::Reviewer'
    one_to_many :reviewer_invites, :class => :'Applyance::ReviewerInvite'
    one_to_many :entities, :class => :'Applyance::Entity', :key => :parent_id
    one_to_many :citizens, :class => :'Applyance::Citizen'

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

    # Get the root entity
    def root_entity
      root = self
      loop do
        break if root.parent_id.nil?
        root = root.parent
      end
      root
    end

    # Check if this entity is the root
    def is_root?
      self.parent_id.nil?
    end

    # Apply the specified function to all child entities
    def apply_to_children(&block)
      self.entities.each do |entity|
        block.call(entity)
        entity.apply_to_children(&block)
      end
    end

    # Attach citizen to the root entity object
    def make_citizen_from_account(account)
      Citizen.find_or_create(
        :account_id => account.id,
        :entity_id => self.root_entity.id
      )
    end

    # Retrieve citizens based on where they applied
    def get_citizens
      citizens = self._get_citizens
      self.apply_to_children { |entity| citizens.concat(entity._get_citizens) }
      citizens.uniq { |c| c.id }.sort_by { |c| c.created_at }.reverse
    end

    def _get_citizens
      citizens = []
      self.applications.each { |a| citizens.concat(a.citizens) }
      citizens
    end

    # Send an email to entity administrators that an application was received
    def send_application_received_email(application)
      self.reviewers_dataset.where(:scope => "admin").each do |reviewer|
        reviewer.send_application_received_email(application)
      end
    end

    # Helper method to get the citizen for this entity for an application
    def citizen_for_application(application)
      application.citizen_for_entity(self)
    end

  end
end
