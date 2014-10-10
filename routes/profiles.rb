module Applyance
  module Routing
    module Profiles

      def self.registered(app)

        # Get profile by Id
        # Must be a reviewer or citizen owner
        app.get '/profiles/:id', :provides => [:json] do
          @profile = Profile.first(:account_id => params['id'])
          if @profile.nil?
            raise BadRequestError.new({ detail: "Profile doesn't exist." })
          end
          protected! app.to_profile_reviewers_or_self(@profile)
          rabl :'profiles/show'
        end

        # Delete a profile by Id
        # Must be the profile owner
        app.delete '/profiles/:id', :provides => [:json] do
          @profile = Profile.first(:id => params['id'])
          if @profile.nil?
            raise BadRequestError.new({ detail: "Profile doesn't exist." })
          end
          protected! app.to_account_id(@profile.account_id)

          @profile.datums_dataset.destroy
          @profile.destroy

          204
        end

      end
    end
  end
end
