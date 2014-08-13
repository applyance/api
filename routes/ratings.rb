module Applyance
  module Routing
    module Ratings

      def self.registered(app)

        # List ratings for citizens
        # Only reviewers can do this
        app.get '/citizens/:id/ratings', :provides => [:json] do
          @citizen = Citizen.first(:id => params[:id])
          @account = protected! app.to_entity_reviewers(@citizen.entity)

          @ratings = @citizen.ratings
          rabl :'ratings/index'
        end

        # Create a new rating
        # Must be a reviewer
        app.post '/citizens/:id/ratings', :provides => [:json] do
          @citizen = Citizen.first(:id => params[:id])
          if @citizen.nil?
            raise BadRequestError.new({ :detail => "Proper citizen ID must be provided." })
          end

          @account = protected! app.to_entity_reviewers(@citizen.entity)
          protected! app.to_account(@account)

          @rating = Rating.new
          @rating.set(:account_id => @account.id, :citizen_id => @citizen.id)
          @rating.set_fields(params, ['rating'], :missing => :skip)
          @rating.save

          status 201
          rabl :'ratings/show'
        end

        # Get rating by Id
        app.get '/ratings/:id', :provides => [:json] do
          @rating = Rating.first(:id => params['id'])
          protected! app.to_entity_reviewers(@rating.citizen.entity)

          rabl :'ratings/show'
        end

        # Update a rating by Id
        # Must be the original reviewer
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
