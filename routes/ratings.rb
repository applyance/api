module Applyance
  module Routing
    module Ratings

      def self.registered(app)

        # List ratings for applications
        # Only reviewers can do this
        app.get '/applications/:id/ratings', :provides => [:json] do
          @application = Application.first(:id => params[:id])
          protected! app.to_application_reviewers(@application)

          @ratings = @application.ratings
          rabl :'ratings/index'
        end

        # Create a new rating
        # Must be a reviewer
        app.post '/accounts/:id/ratings', :provides => [:json] do
          @account = Account.first(:id => params[:id])
          @application = Application.first(:id => params[:application_id])
          if @application.nil?
            raise BadRequestError.new({ :detail => "Proper application ID must be provided." })
          end

          protected! app.to_application_reviewers(@application)
          protected! app.to_account(@account)

          @rating = Rating.new
          @rating.set(:account_id => @account.id)
          @rating.set_fields(params, ['rating', 'application_id'], :missing => :skip)
          @rating.save

          status 201
          rabl :'ratings/show'
        end

        # Get rating by Id
        app.get '/ratings/:id', :provides => [:json] do
          @rating = Rating.first(:id => params['id'])
          protected! app.to_application_reviewers(@rating.application)

          rabl :'ratings/show'
        end

        # Update a rating by Id
        # Must be a reviewer
        app.put '/ratings/:id', :provides => [:json] do
          @rating = Rating.first(:id => params['id'])
          protected! app.to_account(@rating.account)

          @rating.update_fields(params, ['rating'], :missing => :skip)
          rabl :'ratings/show'
        end

        # Delete a rating by Id
        # Must be the owner
        app.delete '/ratings/:id', :provides => [:json] do
          @rating = Rating.first(:id => params['id'])
          protected! app.to_account(@rating.account)

          @rating.destroy

          204
        end

      end
    end
  end
end
