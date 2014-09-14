module Applyance
  module Routing
    module Entities

      def self.registered(app)

        # List top-level entities (for chiefs only)
        # If a slug is provided, filter entities by slug
        app.get '/entities', :provides => [:json] do

          if params[:slug]
            @entity = nil
            parts = params[:slug].split('/')
            if parts.length > 1
              parent = Entity.first(:slug => parts[0], :parent_id => nil)
              @entity = Entity.first(:slug => parts[1], :parent_id => parent.id)
            else
              @entity = Entity.first(:slug => parts[0], :parent_id => nil)
            end
            if @entity.nil?
              error 404
            end
            rabl :'entities/show'
          else
            protected!
            @entities = Entity.all
            rabl :'entities/index'
          end

        end

        # List entities of an entity
        # Only reviewers can do this
        app.get '/entities/:id/entities', :provides => [:json] do
          @entity = Entity.first(:id => params[:id])
          @entities = @entity.entities
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

        # Create a new entity, sans domain
        app.post '/entities', :provides => [:json] do
          @entity = Entity.new
          @entity.set_fields(params, ['name', 'stripe_customer_id'], :missing => :skip)
          @entity.save
          @entity.attach(params['logo'], :logo)
          @entity.locate(params['location'])

          status 201
          rabl :'entities/show'
        end

        # Create a new entity for a domain
        app.post '/domains/:id/entities', :provides => [:json] do
          @domain = Domain.first(:id => params[:id])

          @entity = Entity.new
          @entity.set(:domain_id => @domain.id)
          @entity.set_fields(params, ['name', 'stripe_customer_id'], :missing => :skip)
          @entity.save
          @entity.attach(params['logo'], :logo)
          @entity.locate(params['location'])

          status 201
          rabl :'entities/show'
        end

        # Create a new entity for an entity
        # Only admins can do this
        app.post '/entities/:id/entities', :provides => [:json] do
          @_entity = Entity.first(:id => params[:id])
          protected! app.to_entity_admins(@_entity)

          @entity = Entity.new
          @entity.set(
            :parent_id => @_entity.id,
            :domain_id => @_entity.domain_id)
          @entity.set_fields(params, ['name', 'stripe_customer_id'], :missing => :skip)
          @entity.save
          @entity.attach(params['logo'], :logo)
          @entity.locate(params['location'])

          status 201
          rabl :'entities/show'
        end

        # Get entity by id
        app.get '/entities/:id', :provides => [:json] do
          @entity = Entity.first(:id => params[:id])
          if @entity.nil?
            error 404
          end
          rabl :'entities/show'
        end

        # Update a entity by Id
        # Must be an admin
        app.put '/entities/:id', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          protected! app.to_entity_admins(@entity)

          @entity.update_fields(params, ['name', 'stripe_customer_id'], :missing => :skip)
          @entity.attach(params['logo'], :logo)
          @entity.locate(params['location'])

          rabl :'entities/show'
        end

        # Delete a entity by Id
        # Must be an admin
        app.delete '/entities/:id', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          protected! app.to_entity_admins(@entity)

          @entity.reviewers_dataset.destroy
          @entity.reviewer_invites_dataset.destroy
          @entity.entities_dataset.destroy

          @entity.spots_dataset.destroy
          @entity.templates_dataset.destroy
          @entity.pipelines_dataset.destroy
          @entity.labels_dataset.destroy

          @entity.remove_all_definitions
          @entity.remove_all_blueprints
          @entity.remove_all_applications

          @entity.destroy

          204
        end

      end
    end
  end
end
