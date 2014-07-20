module Applyance
  class Application < Sequel::Model

    include Applyance::Lib::Tokens

    many_to_one :submitter, :class => :'Applyance::Account'
    many_to_one :submitted_from, :class => :'Applyance::Coordinate'
    many_to_one :stage, :class => :'Applyance::Stage'
    many_to_many :spots, :class => :'Applyance::Spot'
    many_to_many :reviewers, :class => :'Applyance::Reviewer'
    many_to_many :labels, :class => :'Applyance::Label'
    one_to_many :activities, :class => :'Applyance::ApplicationActivity'
    one_to_many :threads, :class => :'Applyance::Thread'
    one_to_many :notes, :class => :'Applyance::Note'
    one_to_many :ratings, :class => :'Applyance::Rating'
    one_to_many :fields, :class => :'Applyance::Field'

    def after_create
      super

      # Create submission activity
      ApplicationActivity.make_for_submission(self)
    end

    def make(params)

      # Error checking
      if params[:fields].empty?
        raise BadRequestError({ :detail => "Applications need at least one field." })
      end
      if params[:spot_ids].empty?
        raise BadRequestError({ :detail => "Application spots are required." })
      end
      if params[:submitter].empty?
        raise BadRequestError({ :detail => "Application submitter is required." })
      end

      # Initialize application
      application = self.new
      application.set_token(:digest)

      # Create coordinate
      unless params[:submitted_from].empty?
        coordinate = Coordinate.make(params[:submitted_from])
        application.set(:submitted_from_id => coordinate.id)
      end

      # Create submitter (account)
      account = Account.first_or_make("applicant", {
        :name => params[:submitter][:name],
        :email => params[:submitter][:email],
        :password => friendly_token
      })
      application.set(:submitter_id => account.id)

      # TODO: Send applicant welcome email

      # Assign spots
      params[:spot_ids].each do |spot_id|
        spot = Spot.first(:id => spot_id)
        application.add_spot(spot)
      end

      # Add fields
      params[:fields].each do |field|
        field[:label]
        field[:answer]
        field[:type]
      end

      application.save
      application
    end
  end
end
