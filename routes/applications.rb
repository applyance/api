module Applyance
  module Routing
    module Applications

      def self.registered(app)

        # List applications for spot
        app.get '/spots/:id/applications', :provides => [:json] do
          @spot = Spot.first(:id => params['id'])
          protected! app.to_entity_reviewers(@spot.entity)

          @applications = @spot.applications_dataset.by_last_active
          rabl :'applications/index'
        end

        # List applications for entity
        app.get '/entities/:id/applications', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          protected! app.to_entity_reviewers(@entity)

          @applications = @entity.applications
          @entity.entities.each { |e| @applications.concat(e.applications) }
          @entity.spots.each { |s| @applications.concat(s.applications) }
          @applications = @applications.uniq { |a| a.id }.sort_by { |a| a.last_activity_at }.reverse

          rabl :'applications/index'
        end

        # Create a new application
        # Open to the public
        app.post '/applications', :provides => [:json] do
          @application = Application.make(params)
          status 201
          rabl :'applications/show'
        end

        # Get application by Id
        # Must be a reviewer or application owner
        app.get '/applications/:id', :provides => [:json] do
          @application = Application.first(:id => params['id'])
          if @application.nil?
            raise BaidRequestError.new({ detail: "Application doesn't exist." })
          end
          protected! app.to_application_reviewers_or_self(@application)
          rabl :'applications/show'
        end

        # Update an application by Id
        app.put '/applications/:id', :provides => [:json] do
          @application = Application.first(:id => params['id'])
          protected! app.to_application_reviewers(@application)

          @application.update_fields(params, ['stage_id'], :missing => :skip)

          # Update labels
          unless params['label_ids'].nil?
            @application.remove_all_labels
            params['label_ids'].each do |label_id|
              @application.add_label(Label.first(:id => label_id))
            end
          end

          # Update reviewers
          unless params['reviewer_ids'].nil?
            @application.remove_all_reviewers
            params['reviewer_ids'].each do |reviewer_id|
              @application.add_reviewer(Reviewer.first(:id => reviewer_id))
            end
          end

          rabl :'applications/show'
        end

        # Delete an application by Id
        # Must be an admin
        app.delete '/applications/:id', :provides => [:json] do
          @application = Application.first(:id => params['id'])
          protected! app.to_application_reviewers(@application)

          @application.remove_all_spots
          @application.remove_all_entities
          @application.remove_all_labels
          @application.remove_all_reviewers

          @application.activities_dataset.destroy
          @application.threads_dataset.destroy
          @application.notes_dataset.destroy
          @application.ratings_dataset.destroy
          @application.fields_dataset.destroy
          @application.destroy

          204
        end

      end
    end
  end
end
