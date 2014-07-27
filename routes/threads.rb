module Applyance
  module Routing
    module Threads

      module Protection
        # General protection function for reviewers
        def to_reviewer(reviewer)
          lambda do |account|
            reviewer.account_id == account.id
          end
        end

        def to_reviewers(application)
          lambda do |account|
            application.spots.any? { |s| s.unit.reviewers.collect(&:account_id).include?(account.id) }
          end
        end

        def to_reviewers_or_owner(application)
          lambda do |account|
            return true if application.applicant.account_id == account.id
            application.spots.any? { |s| s.unit.reviewers.collect(&:account_id).include?(account.id) }
          end
        end
      end

      def self.registered(app)

        app.extend(Applyance::Routing::Threads::Protection)

        # List threads for applications
        # Only reviewers or applicant can do this
        app.get '/applications/:id/threads', :provides => [:json] do
          @application = Application.first(:id => params[:id])
          protected! app.to_reviewers_or_owner(@application)

          @threads = @application.threads
          rabl :'threads/index'
        end

        # Create a new thread
        # Must be a reviewer
        app.post '/applications/:id/threads', :provides => [:json] do
          @application = Application.first(:id => params[:application_id])
          protected! app.to_reviewers(@application)

          @thread = Thread.new
          @thread.set(:application_id => @application.id)
          @thread.set_fields(params, ['subject'], :missing => :skip)
          @thread.save

          # Create message

          status 201
          rabl :'threads/show'
        end

        # Get thread by Id
        app.get '/threads/:id', :provides => [:json] do
          @thread = Thread.first(:id => params['id'])
          protected! app.to_reviewers_or_owner(@thread.application)

          rabl :'threads/show'
        end

        # Update a thread by Id
        # Must be a reviewer
        app.put '/threads/:id', :provides => [:json] do
          @thread = Thread.first(:id => params['id'])
          protected! app.to_reviewer(@thread.reviewer)

          @thread.update_fields(params, ['subject'], :missing => :skip)
          rabl :'threads/show'
        end

        # Delete a thread by Id
        # Must be the owner
        app.delete '/threads/:id', :provides => [:json] do
          @thread = Thread.first(:id => params['id'])
          protected! app.to_reviewers(@thread.application)

          @thread.messages_dataset.destroy
          @thread.destroy

          204
        end

      end
    end
  end
end
