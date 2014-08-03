module Applyance
  class Application < Sequel::Model

    include Applyance::Lib::Tokens
    include Applyance::Lib::Strings

    many_to_one :applicant, :class => :'Applyance::Applicant'
    many_to_one :stage, :class => :'Applyance::Stage'

    one_to_many :activities, :class => :'Applyance::ApplicationActivity'
    one_to_many :threads, :class => :'Applyance::Thread'
    one_to_many :notes, :class => :'Applyance::Note'
    one_to_many :ratings, :class => :'Applyance::Rating'
    one_to_many :fields, :class => :'Applyance::Field'

    many_to_many :reviewers, :class => :'Applyance::Reviewer'
    many_to_many :labels, :class => :'Applyance::Label'

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
      if params['applicant'].nil?
        raise BadRequestError.new({ :detail => "Applicant is required." })
      end

      # Initialize application
      application = self.new
      application.set_token(:digest)

      # Create applicant (account)
      temp_password = application.friendly_token
      account = Account.first(:email => params['applicant']['email'])
      account_found = !!account
      unless account_found
        account = Account.make("applicant", {
          'name' => params['applicant']['name'],
          'email' => params['applicant']['email'],
          'password' => temp_password
        })
      end

      applicant = Applicant.find_or_create(:account_id => account.id)
      unless account_found
        applicant.send_welcome_email(temp_password)
      end

      unless params['applicant']['phone_number'].nil?
        applicant.update(:phone_number => params['applicant']['phone_number'])
      end

      # Create applicant location
      unless params['applicant']['location'].nil?
        location = Location.make(params['applicant']['location'])
        applicant.update(:location_id => location.id)
      end

      # Save so we can add assocations
      application.set(:applicant_id => applicant.id)
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

      # TODO: Send applicant welcome email

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
        datum = Datum.new
        datum.applicant = self.applicant

        # Figure out the definition
        if field[:datum][:definition]
          definition = Definition.make_from_field_for_spots(field[:datum], self.spots)
        elsif field[:datum][:definition_id]
          definition = Definition.first(:id => field[:datum][:definition_id])
        else
          raise BadRequestError.new({ :detail => "Must supply a definition for all fields." })
        end
        datum.definition = definition
      end

      datum.detail = field[:datum][:detail]
      datum.save

      field_obj = Field.create(:datum_id => datum.id)
      self.add_field(field_obj)

    end
  end
end
