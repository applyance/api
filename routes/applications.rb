module Applyance
  module Routing
    module Applications

      module Protection

        # Protection to admins of entity
        def to_admins(entity)
          lambda do |account|
            entity.reviewers_dataset.where(:scope => "admin").collect(&:account_id).include?(account.id)
          end
        end

        # Protection to reviewers of entity
        def to_reviewers(entity)
          lambda do |account|
            entity.reviewers.collect(&:account_id).include?(account.id)
          end
        end

        # Protection to reviewers of application
        def to_reviewers_of_application(application)
          lambda do |account|
            return true if application.spots.any? { |s| s.entity.reviewers.collect(&:account_id).include?(account.id) }
            application.entities.any? { |e| e.reviewers.collect(&:account_id).include?(account.id)  }
          end
        end

        # Protection to reviewers or self
        def to_reviewers_or_self(application)
          lambda do |account|
            return true if account.id == application.applicant.account_id
            to_reviewers_of_application(application).(account)
          end
        end

      end

      def self.registered(app)

        app.extend(Applyance::Routing::Applications::Protection)

        # List applications for spot
        app.get '/spots/:id/applications', :provides => [:json] do
          @spot = Spot.first(:id => params['id'])
          protected! app.to_reviewers(@spot.entity)

          @applications = @spot.applications_dataset.by_last_active
          rabl :'applications/index'
        end

        # List applications for entity
        app.get '/entities/:id/applications', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          puts "------------------1"
          puts @entity.inspect
          protected! app.to_reviewers(@entity)

          puts "------------------2"

          @applications = @entity.applications
          @entity.spots.each { |s| @applications.concat(s.applications) }
          @applications = @applications.uniq { |a| a.id }.sort_by { |a| a.last_activity_at }.reverse

          puts "------------------3"

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
          protected! app.to_reviewers_or_self(@application)
          rabl :'applications/show'
        end

        # Update an application by Id
        app.put '/applications/:id', :provides => [:json] do
          @application = Application.first(:id => params['id'])
          protected! app.to_reviewers_of_application(@application)

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
          protected! app.to_admins(@application)

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
