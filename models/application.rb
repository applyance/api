module Applyance
  class Application < Sequel::Model

    include Applyance::Lib::Tokens
    include Applyance::Lib::Strings

    many_to_one :citizen, :class => :'Applyance::Citizen'

    one_to_many :activities, :class => :'Applyance::ApplicationActivity'
    one_to_many :notes, :class => :'Applyance::Note'
    one_to_many :fields, :class => :'Applyance::Field'

    many_to_many :reviewers, :class => :'Applyance::Reviewer'
    many_to_many :spots, :class => :'Applyance::Spot'
    many_to_many :entities, :class => :'Applyance::Entity'

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
      if params['citizen'].nil?
        raise BadRequestError.new({ :detail => "Citizen is required." })
      end

      # Initialize application
      application = self.new
      application.set_token(:digest)

      # Create citizen (account)
      temp_password = application.friendly_token
      account = Account.first(:email => params['citizen']['email'])
      account_found = !!account
      unless account_found
        account = Account.make("citizen", {
          'name' => params['citizen']['name'],
          'email' => params['citizen']['email'],
          'password' => temp_password
        })
      end

      citizen = Citizen.find_or_create(:account_id => account.id)
      unless account_found
        citizen.send_welcome_email(temp_password)
      end

      unless params['citizen']['phone_number'].nil?
        citizen.update(:phone_number => params['citizen']['phone_number'])
      end

      # Create citizen location
      unless params['citizen']['location'].nil?
        location = Location.make(params['citizen']['location'])
        if location
          citizen.update(:location_id => location.id)
        end
      end

      # Save so we can add assocations
      application.set(:citizen_id => citizen.id)
      application.save

      # Assign spots
      if params['spot_ids']
        params['spot_ids'].each do |spot_id|
          spot = Spot.first(:id => spot_id)
          application.add_spot(spot)
        end
      end

      # Assign entities
      if params['entity_ids']
        params['entity_ids'].each do |entity_id|
          entity = Entity.first(:id => entity_id)
          application.add_entity(entity)
        end
      end

      # Add fields
      params['fields'].each do |field|
        application.add_field_from_datum(field)
      end

      application.update(:submitted_at => DateTime.now)

      application
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
        if definition.is_contextual
          datum = Datum.new
          datum.citizen = self.citizen
          datum.definition = definition
        else
          datum = Datum.first(
            :definition_id => definition.id,
            :citizen_id => self.citizen.id
          )
          if datum.nil?
            datum = Datum.new
            datum.citizen = self.citizen
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
