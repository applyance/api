module Applyance
  class Application < Sequel::Model

    include Applyance::Lib::Tokens
    include Applyance::Lib::Strings

    one_to_many :activities, :class => :'Applyance::ApplicationActivity'
    one_to_many :notes, :class => :'Applyance::Note'
    one_to_many :fields, :class => :'Applyance::Field'

    many_to_many :reviewers, :class => :'Applyance::Reviewer'
    many_to_many :spots, :class => :'Applyance::Spot'
    many_to_many :entities, :class => :'Applyance::Entity'
    many_to_many :citizens, :class => :'Applyance::Citizen'

    dataset_module do
      def by_last_active
        reverse_order(:last_activity_at)
      end
    end

    def after_create
      super

      # Create submission activity
      ApplicationActivity.make_for_submission(self)
    end

    # Create the application from given request parameters
    def self.make(params)

      # Error checking
      if params['fields'].nil?
        raise BadRequestError.new({ :detail => "Applications need at least one field." })
      end
      if params['spot_ids'].nil? && params['entity_ids'].nil?
        raise BadRequestError.new({ :detail => "Applications need to be assigned entities or spots." })
      end
      if params['applicant'].nil?
        raise BadRequestError.new({ :detail => "Applicant is required." })
      end

      # Initialize application
      application = self.new
      application.set_token(:digest)

      # Create account and profile
      temp_password = application.friendly_token
      account = Account.first(:email => params['applicant']['email'])
      account_found = !!account
      account = Account.make("citizen", {
        'name' => params['applicant']['name'],
        'email' => params['applicant']['email'],
        'password' => temp_password
      })

      profile = Profile.find_or_create(:account_id => account.id)
      unless account_found
        profile.send_welcome_email(temp_password)
      end

      unless params['applicant']['phone_number'].nil?
        profile.update(:phone_number => params['applicant']['phone_number'])
      end

      # Create profile location
      unless params['applicant']['location'].nil?
        location = Location.make(params['applicant']['location'])
        if location
          profile.update(:location_id => location.id)
        end
      end

      application.save

      # Assign spots and entities
      application.link_spots_from_params(params)
      application.link_entities_from_params(params)

      # Create citizens
      citizens = []
      application.spots.each { |s| citizens << s.entity.make_citizen_from_account(account) }
      application.entities.each { |e| citizens << e.make_citizen_from_account(account) }
      citizens.uniq { |c| c.id }.each { |c| application.add_citizen(c) }

      # Add fields
      params['fields'].each { |f| application.add_field_from_datum(f) }

      application.update(:submitted_at => DateTime.now)

      application
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

      datum.detail = field[:datum][:detail]
      datum.save

      field_obj = Field.create(:datum_id => datum.id)
      self.add_field(field_obj)

    end
  end
end
