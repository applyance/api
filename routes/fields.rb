module Applyance
  module Routing
    module Fields

      module Protection

        # Protection to full-access reviewers
        def to_reviewers_or_owner_field(field)
          lambda do |account|
            return true if field.datum.account_id == account.id
            field.application.spots.any? do |spot|
              spot.unit.reviewers.collect(&:account_id).include?(account.id)
            end
          end
        end

        # Protection to full-access reviewers
        def to_reviewers_or_owner_application(application)
          lambda do |account|
            return true if application.submitter_id == account.id
            application.spots.any? do |spot|
              spot.unit.reviewers.collect(&:account_id).include?(account.id)
            end
          end
        end

      end

      def self.registered(app)

        app.extend(Applyance::Routing::Fields::Protection)

        # List fields for application
        # Must be reviewer or application owner
        app.get '/applications/:id/fields', :provides => [:json] do
          @application = Application.first(:id => params['id'])
          protected! app.to_reviewers_or_owner_application(@application)
          @fields = @application.fields
          rabl :'fields/index'
        end

        # Create a new field for an application
        # Must be reviewer or application owner
        app.post '/applications/:id/fields', :provides => [:json] do
          @application = Application.first(:id => params['id'])
          protected! app.to_reviewers_or_owner_application(@application)

          @field = Field.new
          @field.set(:application_id => @application.id)
          @field.set_fields(params, ['datum_id'], :missing => :skip)
          @field.save

          status 201
          rabl :'fields/show'
        end

        # Get field by Id
        app.get '/fields/:id', :provides => [:json] do
          @field = Field.first(:id => params['id'])
          protected! app.to_reviewers_or_owner_field(@field)
          rabl :'fields/show'
        end

        # Delete a field by Id
        # Must be a reviewer or owner
        app.delete '/fields/:id', :provides => [:json] do
          @field = Field.first(:id => params['id'])
          protected! app.to_reviewers_or_owner_field(@field)

          @field.destroy

          204
        end

      end
    end
  end
end
