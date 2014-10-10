module Applyance
  class Application < Sequel::Model

    include Applyance::Lib::Tokens
    include Applyance::Lib::Strings

    one_to_many :notes, :class => :'Applyance::Note'
    one_to_many :fields, :class => :'Applyance::Field'

    many_to_many :reviewers, :class => :'Applyance::Reviewer'
    many_to_many :spots, :class => :'Applyance::Spot'
    many_to_many :entities, :class => :'Applyance::Entity'
    many_to_many :citizens, :class => :'Applyance::Citizen'

    # Create the application from given request parameters
    def self.make(params)

      self.ensure_valid_params(params)

      # Initialize application
      application = self.new
      application.set_token(:digest)
      application.save

      # Create account and profile
      account = application.create_applicant_account(params)
      profile = Profile.find_or_create(:account_id => account.id)

      # Assign spots and entities
      application.link_spots_from_params(params)
      application.link_entities_from_params(params)

      # Create citizens
      citizens = []
      application.spots.each { |s| citizens << s.entity.make_citizen_from_account(account) }
      application.entities.each { |e| citizens << e.make_citizen_from_account(account) }
      citizens.uniq { |c| c.id }.each { |c| application.add_citizen(c) }
      CitizenActivity.make_for_application_submission(application)

      # Add fields
      params['fields'].each { |f| application.add_field_from_datum(f) }

      # Finalize the application
      application.update(:submitted_at => DateTime.now)

      # Send email to reviewers (administrators)
      application.notify_reviewers

      application
    end

    # Make sure the params are valid
    def self.ensure_valid_params(params)
      if params['fields'].nil?
        raise BadRequestError.new({ :detail => "Applications need at least one field." })
      end
      if params['spot_ids'].nil? && params['entity_ids'].nil?
        raise BadRequestError.new({ :detail => "Applications need to be assigned entities or spots." })
      end
      if params['account'].nil? && params['account_id'].nil?
        raise BadRequestError.new({ :detail => "Account is required." })
      end
    end

    # Creates the applicant account
    def create_applicant_account(params)
      params['account_id'] ? create_existing_account(params) : create_new_account(params)
    end

    # If the user passed in an account_id, ensure the existing account
    # is correct
    def create_existing_account(params)
      account = Account.first(:id => params['account_id'])
      if account.nil?
        raise BadRequestError.new({ :detail => "Account specified doesn't exist." })
      end
      unless account.has_role?("citizen")
        account.add_role(Role.first(:name => "citizen"))
      end
      account
    end

    # If the user passed in an account name and email, make the
    # new account (or just use the one that exists)
    def create_new_account(params)
      account = Account.make("citizen", {
        'name' => params['account']['name'],
        'email' => params['account']['email'],
        'password' => self.friendly_token
      })
      account
    end

    # Link the spot IDs in params to the application
    def link_spots_from_params(params)
      return unless params['spot_ids']
      params['spot_ids'].uniq.each do |spot_id|
        spot = Spot.first(:id => spot_id)
        self.add_spot(spot)
      end
    end

    # Link the entity IDs in params to the application
    def link_entities_from_params(params)
      return unless params['entity_ids']
      params['entity_ids'].uniq.each do |entity_id|
        entity = Entity.first(:id => entity_id)
        self.add_entity(entity)
      end
    end

    # Send a notification to all reviewers that a new application was received
    def notify_reviewers
      reviewer_ids = []
      self.entities.each { |e| reviewer_ids.concat(e.reviewers_dataset.where(:scope => "admin").collect(&:id)) }
      reviewers = Reviewer.where(:id => reviewer_ids).all.uniq { |r| r.account_id }
      reviewers.each { |r| r.send_application_received_email(self) }
    end

    # Create a field from the given datum parameter
    def add_field_from_datum(field)
      if field[:datum].nil? && field[:datum_id].nil?
        raise BadRequestError.new({ :detail => "Must supply a datum for all fields." })
      end

      if field[:datum_id]
        field_obj = Field.create(:datum_id => field[:datum_id])
        self.add_field(field_obj)
        return
      end

      if field[:datum][:id]
        datum = Datum.first(:id => field[:datum][:id])
      else

        # Try to coerce a definition first
        if field[:datum][:definition]
          definition = Definition.make_from_field_for_spots(field[:datum], self.spots)
        elsif field[:datum][:definition_id]
          definition = Definition.first(:id => field[:datum][:definition_id])
        else
          raise BadRequestError.new({ :detail => "Must supply a definition for all fields." })
        end

        # If not contextual, see if a datum exists for this definition already
        profile = Profile.first(:account_id => self.citizens.first.account_id)

        if definition.is_contextual
          datum = Datum.new
          datum.profile = profile
          datum.definition = definition
        else
          datum = Datum.first(
            :definition_id => definition.id,
            :profile_id => profile.id
          )
          if datum.nil?
            datum = Datum.new
            datum.profile = profile
            datum.definition = definition
          end
        end
      end

      datum.detail = field[:datum][:detail] if field[:datum][:detail]
      datum.save
      datum.attach(field[:datum][:attachments], :attachments) if field[:datum][:attachments]

      field_obj = Field.create(:datum_id => datum.id)
      self.add_field(field_obj)

    end

    # Helper method to get the citizen of this application for an entity
    def citizen_for_entity(entity)
      self.citizens.detect { |c| c.entity_id == entity.root_entity.id }
    end

  end
end
