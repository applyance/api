module Applyance
  module Routing
    module Entities

      module Protection
        # General protection function for entity admins
        def to_admins(entity)
          lambda { |account| entity.admins.collect(&:account_id).include?(account.id) }
        end
      end

      def self.registered(app)

        app.extend(Applyance::Routing::Entities::Protection)

        # List entities
        # Only Chiefs can do this B)
        app.get '/entities', :provides => [:json] do
          protected!
          @entities = Entity.all
          rabl :'entities/index'
        end

        # List entities by domain
        # Only Chiefs can do this B)
        app.get '/domains/:id/entities', :provides => [:json] do
          protected!
          @domain = Domain.first(:id => params['id'])
          @entities = @domain.entities
          rabl :'entities/index'
        end

        # Create a new entity
        app.post '/entities', :provides => [:json] do
          @entity = Entity.new
          @entity.set_fields(params, ['name', 'domain_id'], :missing => :skip)
          @entity.save
          @entity.attach(params['logo'], :logo)
          status 201
          rabl :'entities/show'
        end

        # Get entity by Id
        app.get '/entities/:id', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          rabl :'entities/show'
        end

        # Update a entity by Id
        # Must be an admin
        app.put '/entities/:id', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          protected! app.to_admins(@entity)
          @entity.update_fields(params, ['name', 'domain_id'], :missing => :skip)
          @entity.attach(params['logo'], :logo)
          rabl :'entities/show'
        end

        # Delete a entity by Id
        # Must be an admin
        app.delete '/entities/:id', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          protected! app.to_admins(@entity)

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
