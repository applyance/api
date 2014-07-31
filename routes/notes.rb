module Applyance
  module Routing
    module Notes

      module Protection
        # General protection function for reviewers
        def to_reviewer(reviewer)
          lambda do |account|
            reviewer.account_id == account.id
          end
        end

        def to_reviewers(application)
          lambda do |account|
            application.spots.any? { |s| s.entity.reviewers.collect(&:account_id).include?(account.id) }
          end
        end
      end

      def self.registered(app)

        app.extend(Applyance::Routing::Notes::Protection)

        # List notes for applications
        # Only reviewers can do this
        app.get '/applications/:id/notes', :provides => [:json] do
          @application = Application.first(:id => params[:id])
          protected! app.to_reviewers(@application)

          @notes = @application.notes
          rabl :'notes/index'
        end

        # Create a new note
        # Must be a reviewer
        app.post '/reviewers/:id/notes', :provides => [:json] do
          @reviewer = Reviewer.first(:id => params[:id])
          @application = Application.first(:id => params[:application_id])

          if @application.nil?
            raise BadRequestError.new({ :detail => "Proper application ID must be provided." })
          end

          protected! app.to_reviewers(@application)
          protected! app.to_reviewer(@reviewer)

          @note = Note.new
          @note.set(:reviewer_id => @reviewer.id)
          @note.set_fields(params, ['note', 'application_id'], :missing => :skip)
          @note.save

          status 201
          rabl :'notes/show'
        end

        # Get note by Id
        app.get '/notes/:id', :provides => [:json] do
          @note = Note.first(:id => params['id'])
          protected! app.to_reviewers(@note.application)

          rabl :'notes/show'
        end

        # Update a note by Id
        # Must be the owner
        app.put '/notes/:id', :provides => [:json] do
          @note = Note.first(:id => params['id'])
          protected! app.to_reviewer(@note.reviewer)

          @note.update_fields(params, ['note'], :missing => :skip)
          rabl :'notes/show'
        end

        # Delete a note by Id
        # Must be the owner
        app.delete '/notes/:id', :provides => [:json] do
          @note = Note.first(:id => params['id'])
          protected! app.to_reviewer(@note.reviewer)

          @note.destroy

          204
        end

      end
    end
  end
end
