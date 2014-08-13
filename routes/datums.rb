module Applyance
  module Routing
    module Datums

      def self.registered(app)

        # List datums for profile
        # Must be account owner
        app.get '/profiles/:id/datums', :provides => [:json] do
          @profile = Profile.first(:id => params['id'])
          if @profile.nil?
            raise BadRequestError.new({ detail: "Profile doesn't exist." })
          end
          protected! app.to_account_id(@profile.account_id)
          @datums = @profile.datums
          rabl :'datums/index'
        end

        # Create a new datum for a profile
        # Must be account owner
        app.post '/profiles/:id/datums', :provides => [:json] do
          @profile = Profile.first(:id => params['id'])
          if @profile.nil?
            raise BadRequestError.new({ detail: "Profile doesn't exist." })
          end
          protected! app.to_account_id(@profile.account_id)

          @datum = Datum.new
          @datum.set(:profile_id => @profile.id)
          @datum.set_fields(params, ['definition_id', 'detail'], :missing => :skip)
          @datum.save
          @datum.attach(params['attachments'], :attachments)

          status 201
          rabl :'datums/show'
        end

        # Get datum by Id
        app.get '/datums/:id', :provides => [:json] do
          @datum = Datum.first(:id => params['id'])
          rabl :'datums/show'
        end

        # Update a datum by Id
        # Must be an account owner
        app.put '/datums/:id', :provides => [:json] do
          @datum = Datum.first(:id => params['id'])
          protected! app.to_account_id(@datum.profile.account_id)

          @datum.update_fields(params, ['detail'], :missing => :skip)
          @datum.attach(params['attachments'], :attachments)
          rabl :'datums/show'
        end

        # Delete a datum by Id
        # Must be account owner
        app.delete '/datums/:id', :provides => [:json] do
          @datum = Datum.first(:id => params['id'])

          protected! app.to_account_id(@datum.profile.account_id)

          @datum.fields_dataset.destroy
          @datum.attachments_dataset.destroy
          @datum.remove_all_attachments
          @datum.destroy

          204
        end

      end
    end
  end
end
