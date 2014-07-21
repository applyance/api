module Applyance
  module Routing
    module Datums

      module Protection
        # Protection to account
        def to_account_owner(owner)
          lambda do |account|
            account.id == owner.id
          end
        end
      end

      def self.registered(app)

        app.extend(Applyance::Routing::Datums::Protection)

        # List datums for account
        # Must be account owner
        app.get '/accounts/:id/datums', :provides => [:json] do
          @account = Account.first(:id => params['id'])
          protected! app.to_account_owner(@account)
          @datums = @account.datums
          rabl :'datums/index'
        end

        # Create a new datum for an account
        # Must be account owner
        app.post '/accounts/:id/datums', :provides => [:json] do
          @account = Account.first(:id => params['id'])
          protected! app.to_account_owner(@account)

          @datum = Datum.new
          @datum.set(:account_id => @account.id)
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
          protected! app.to_account_owner(@datum.account)

          @datum.update_fields(params, ['detail'], :missing => :skip)
          @datum.attach(params['attachments'], :attachments)
          rabl :'datums/show'
        end

        # Delete a datum by Id
        # Must be account owner
        app.delete '/datums/:id', :provides => [:json] do
          @datum = Datum.first(:id => params['id'])

          protected! app.to_account_owner(@datum.account)

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
