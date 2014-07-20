module Applyance
  module Routing
    module Admins
      def self.registered(app)

        # General protection function for entity admins
        to_admins = lambda do |entity|
          lambda { |account| entity.admins.collect(&:account_id).include?(account.id) }
        end

        # List admins for an entity
        app.get '/entities/:id/admins', :provides => [:json] do
          @entity = Entity.first(:id => params[:id])
          protected! to_admins(@entity)
          @admins = @entity.admins
          rabl :'admins/index'
        end

        # Get admin by Id
        app.get '/admins/:id', :provides => [:json] do
          @admin = Admin.first(:id => params[:id])
          protected! to_admins(@admin.entity)
          rabl :'admins/show'
        end

        # Delete an admin by Id
        app.delete '/admins/:id', :provides => [:json] do
          @admin = Admin.first(:id => params[:id])
          protected! to_admins(@admin.entity)

          @entity.admins_dataset.destroy
          @entity.admin_invites_dataset.destroy
          @entity.units_dataset.destroy
          @entity.destroy

          204
        end

      end
    end
  end
end
