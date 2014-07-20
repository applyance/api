module Applyance
  module Routing
    module Entities
      def self.registered(app)

        # General protection function for entity admins
        to_admins = lambda do |entity|
          lambda { |account| entity.admins.collect(&:account_id).include?(account.id) }
        end

        # List entities
        # Only Chiefs can do this B)
        app.get '/entities', :provides => [:json] do
          protected!
          @entities = Entity.all
          rabl :'entities/index'
        end

        # Create a new entity
        # Only Chiefs can do this B)
        app.post '/entities', :provides => [:json] do
          protected!
          @entity = Entity.new
          @entity.set_fields(params, [:name, :domain_id], :missing => :skip)
          @entity.save
          status 201
          rabl :'entities/show'
        end

        # Get entity by Id
        app.get '/entities/:id', :provides => [:json] do
          @entity = Entity.first(:id => params[:id])
          rabl :'entities/show'
        end

        # Update a entity by Id
        # Must be an admin
        app.put '/entities/:id', :provides => [:json] do
          @entity = Entity.first(:id => params[:id])
          @account = protected! to_admins(@entity)

          allowed_fields = @account.has_role?("chief") ? [:name, :domain_id] : [:name]

          @entity.update_fields(params, allowed_fields, :missing => :skip)
          rabl :'entities/show'
        end

        # Delete a entity by Id
        # Must be an admin
        app.delete '/entities/:id', :provides => [:json] do
          @entity = Entity.first(:id => params[:id])
          protected! to_admins(@entity)

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
