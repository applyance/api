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
      account_exists = !!Account.first(Sequel.ilike(:email, params['applicant']['email']))
      temp_password = application.friendly_token
      account = application.create_applicant_account(params, temp_password)
      profile = application.create_applicant_profile(params, account, temp_password, !account_exists)

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
      if params['applicant'].nil?
        raise BadRequestError.new({ :detail => "Applicant is required." })
      end
    end

    # Creates the applicant account
    def create_applicant_account(params, temp_password)
      account = Account.make("citizen", {
        'name' => params['applicant']['name'],
        'email' => params['applicant']['email'],
        'password' => temp_password
      })
      account
    end

    # Creates the applicant profile
    def create_applicant_profile(params, account, temp_password, send_email = true)
      profile = Profile.find_or_create(:account_id => account.id)

      if params['applicant']['phone_number']
        profile.update(:phone_number => params['applicant']['phone_number'])
      end

      # Create profile location
      unless params['applicant']['location'].nil?
        location = Location.make(params['applicant']['location'])
        profile.update(:location_id => location.id) if location
      end

      # Send the profile if an account is new
      if send_email
        profile.send_welcome_email(temp_password)
      end

      profile
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
