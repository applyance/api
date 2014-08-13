module Applyance
  module Routing
    module Labels

      def self.registered(app)

        # List labels by entity
        # Only reviewers can do this
        app.get '/entities/:id/labels', :provides => [:json] do
          @entity = Entity.first(:id => params[:id])
          protected! app.to_entity_reviewers(@entity)
          @labels = @entity.labels
          rabl :'labels/index'
        end

        # List labels by citizen
        # Only reviewers can do this
        app.get '/citizens/:id/labels', :provides => [:json] do
          @citizen = Citizen.first(:id => params[:id])
          protected! app.to_entity_reviewers(@citizen.entity)
          @labels = @citizen.labels
          rabl :'labels/index'
        end

        # Create a new label
        # Must be an admin
        app.post '/entities/:id/labels', :provides => [:json] do
          @entity = Entity.first(:id => params[:id])
          protected! app.to_entity_admins(@entity)

          @label = Label.new
          @label.set(:entity_id => @entity.id)
          @label.set_fields(params, ['name', 'color'], :missing => :skip)
          @label.save

          status 201
          rabl :'labels/show'
        end

        # Get label by Id
        app.get '/labels/:id', :provides => [:json] do
          @label = Label.first(:id => params['id'])
          protected! app.to_entity_reviewers(@label.entity)

          rabl :'labels/show'
        end

        # Update a label by Id
        # Must be an admin
        app.put '/labels/:id', :provides => [:json] do
          @label = Label.first(:id => params['id'])
          protected! app.to_entity_admins(@label.entity)

          @label.update_fields(params, ['name', 'color'], :missing => :skip)
          rabl :'labels/show'
        end

        # Delete a label by Id
        # Must be an admin
        app.delete '/labels/:id', :provides => [:json] do
          @label = Label.first(:id => params['id'])
          protected! app.to_entity_admins(@label.entity)

          @label.destroy

          204
        end

      end
    end
  end
end
