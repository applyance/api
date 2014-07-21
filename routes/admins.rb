module Applyance
  module Routing
    module Admins

      module Protection
        # General protection function for entity admins
        def to_admins(entity)
          lambda { |account| entity.admins.collect(&:account_id).include?(account.id) }
        end
      end

      def self.registered(app)

        app.extend(Applyance::Routing::Admins::Protection)

        # List admins for an entity
        app.get '/entities/:id/admins', :provides => [:json] do
          @entity = Entity.first(:id => params[:id])
          protected! app.to_admins(@entity)
          @admins = @entity.admins
          rabl :'admins/index'
        end

        # Create admin for entity
        app.post '/entities/:id/admins', :provides => [:json] do
          @entity = Entity.first(:id => params[:id])

          if @entity.nil?
            raise BadRequestError({ :detail => "Must be a valid entity." })
          end

          account = Account.make("admin", params)
          @admin = Admin.create(
            :entity_id => @entity.id,
            :account_id => account.id)

          status 201
          rabl :'admins/show'
        end

        # Get admin by Id
        app.get '/admins/:id', :provides => [:json] do
          @admin = Admin.first(:id => params[:id])
          protected! app.to_admins(@admin.entity)
          rabl :'admins/show'
        end

        # Delete an admin by Id
        app.delete '/admins/:id', :provides => [:json] do
          @admin = Admin.first(:id => params[:id])
          protected! app.to_admins(@admin.entity)

          @admin.destroy

          204
        end

      end
    end
  end
end
