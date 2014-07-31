module Applyance
  module Routing
    module Fields

      def self.registered(app)

        # List fields for application
        # Must be reviewer or application owner
        app.get '/applications/:id/fields', :provides => [:json] do
          @application = Application.first(:id => params['id'])
          protected! app.to_application_reviewers_or_self(@application)
          @fields = @application.fields
          rabl :'fields/index'
        end

        # Create a new field for an application
        # Must be reviewer or application owner
        app.post '/applications/:id/fields', :provides => [:json] do
          @application = Application.first(:id => params['id'])
          protected! app.to_application_reviewers_or_self(@application)

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
          protected! app.to_field_reviewers_or_self(@field)
          rabl :'fields/show'
        end

        # Delete a field by Id
        # Must be a reviewer or owner
        app.delete '/fields/:id', :provides => [:json] do
          @field = Field.first(:id => params['id'])
          protected! app.to_field_reviewers_or_self(@field)

          @field.destroy

          204
        end

      end
    end
  end
end
