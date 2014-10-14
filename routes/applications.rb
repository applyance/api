module Applyance
  module Routing
    module Applications

      def self.registered(app)

        # List all applications
        # Only chiefs can do this
        app.get '/applications', :provides => [:json] do
          protected!
          @applications = Application.reverse_order(:created_at).all
          rabl :'applications/index'
        end

        # List applications for a citizen
        app.get '/citizens/:id/applications', :provides => [:json] do
          @citizen = Citizen.first(:id => params['id'])
          protected! app.to_entity_reviewers(@citizen.entity)

          @applications = @citizen.applications_dataset
          rabl :'applications/index'
        end

        # List applications for spot
        app.get '/spots/:id/applications', :provides => [:json] do
          @spot = Spot.first(:id => params['id'])
          protected! app.to_entity_reviewers(@spot.entity)
          paywall! @spot.entity, 'applicantList'

          @applications = @spot.applications_dataset
          rabl :'applications/index'
        end

        # List applications for entity
        app.get '/entities/:id/applications', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          protected! app.to_entity_reviewers(@entity)
          paywall! @entity, 'applicantList'

          @applications = @entity.applications
          @entity.entities.each { |e| @applications.concat(e.applications) }
          @entity.spots.each { |s| @applications.concat(s.applications) }
          @applications = @applications.uniq { |a| a.id }

          rabl :'applications/index'
        end

        # Create a new application
        # Open to the public
        app.post '/applications', :provides => [:json] do
          @application = Application.make(params)
          status 201
          rabl :'applications/show'
        end

        # Export an application as a PDF
        app.get '/applications/:id.pdf' do
          @application = Application.first(:id => params['id'])
          if @application.nil?
            raise BadRequestError.new({ detail: "Application doesn't exist." })
          end
          protected! app.to_application_reviewers_or_self(@application)

          account = @application.citizens.first.account

          response.headers['Content-Type'] = 'application/pdf'
          response.headers['Content-Disposition'] = "attachment; filename=\"#{account.name}.pdf\""
          response.headers['Cache-Control'] = 'no-cache'

          @application.render_pdf
        end

        # Get application by Id
        # Must be a reviewer or application owner
        app.get '/applications/:id', :provides => [:json] do
          @application = Application.first(:id => params['id'])
          if @application.nil?
            raise BadRequestError.new({ detail: "Application doesn't exist." })
          end
          protected! app.to_application_reviewers_or_self(@application)
          rabl :'applications/show'
        end

        # Update an application by Id
        app.put '/applications/:id', :provides => [:json] do
          @application = Application.first(:id => params['id'])
          protected! app.to_application_reviewers(@application)

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
          @application.remove_all_reviewers
          @application.remove_all_citizens

          @application.notes_dataset.destroy
          @application.fields_dataset.destroy

          @application.destroy

          204
        end

      end
    end
  end
end
