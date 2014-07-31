module Applyance
  module Routing
    module Datums

      def self.registered(app)

        # List datums for applicant
        # Must be account owner
        app.get '/applicants/:id/datums', :provides => [:json] do
          @applicant = Applicant.first(:id => params['id'])
          protected! app.to_account(@applicant.account)
          @datums = @applicant.datums
          rabl :'datums/index'
        end

        # Create a new datum for an account
        # Must be account owner
        app.post '/applicants/:id/datums', :provides => [:json] do
          @applicant = Applicant.first(:id => params['id'])
          protected! app.to_account(@applicant.account)

          @datum = Datum.new
          @datum.set(:applicant_id => @applicant.id)
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
          protected! app.to_account(@datum.applicant.account)

          @datum.update_fields(params, ['detail'], :missing => :skip)
          @datum.attach(params['attachments'], :attachments)
          rabl :'datums/show'
        end

        # Delete a datum by Id
        # Must be account owner
        app.delete '/datums/:id', :provides => [:json] do
          @datum = Datum.first(:id => params['id'])

          protected! app.to_account(@datum.applicant.account)

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
