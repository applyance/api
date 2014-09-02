module Applyance
  module Routing
    module Definitions

      def self.registered(app)

        app.get '/definitions', :provides => [:json] do
          @definitions = Definition.exclude(:id => app.db[:definitions_entities].select(:definition_id)).by_first_created
          rabl :'definitions/index'
        end

        # List definitions for entity
        # Must be an admin
        app.get '/entities/:id/definitions', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          protected! app.to_entity_admins(@entity)
          @definitions = @entity.definitions_dataset.by_first_created
          rabl :'definitions/index'
        end

        # List definitions for domain
        app.get '/domains/:id/definitions', :provides => [:json] do
          @domain = Domain.first(:id => params['id'])
          @definitions = @domain.definitions_dataset.by_first_created
          rabl :'definitions/index'
        end

        # Create a new definition
        # Must be an admin
        app.post '/entities/:id/definitions', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          protected! app.to_entity_admins(@entity)

          unless @entity.definitions.count < 5
            raise BadRequestError.new({ detail: "Entities can only have 5 definitions." })
          end

          @definition = Definition.new
          @definition.set_fields(params, ['name', 'label', 'description', 'type', 'helper'], :missing => :skip)
          @definition.save

          @entity.add_definition(@definition)

          status 201
          rabl :'definitions/show'
        end

        # Create a new definition
        # Must be a chief B)
        app.post '/domains/:id/definitions', :provides => [:json] do
          protected!

          @domain = Domain.first(:id => params['id'])

          @definition = Definition.new
          @definition.set_fields(params, ['name', 'label', 'description', 'type', 'helper'], :missing => :skip)
          @definition.save

          @domain.add_definition(@definition)

          status 201
          rabl :'definitions/show'
        end

        # Create a new definition that's not tied to a domain
        # Must be a chief B)
        app.post '/definitions', :provides => [:json] do
          protected!

          @definition = Definition.new
          @definition.set_fields(params, ['name', 'label', 'description', 'type', 'helper'], :missing => :skip)
          @definition.save

          status 201
          rabl :'definitions/show'
        end

        # Get definition by Id
        app.get '/definitions/:id', :provides => [:json] do
          @definition = Definition.first(:id => params['id'])
          rabl :'definitions/show'
        end

        # Update a definition by Id
        app.put '/definitions/:id', :provides => [:json] do
          @definition = Definition.first(:id => params['id'])

          protected! if @definition.domain
          protected! app.to_entity_admins(@definition.entity) if @definition.entity

          @definition.update_fields(params, ['name', 'label', 'description', 'type', 'helper'], :missing => :skip)
          rabl :'definitions/show'
        end

        # Delete a definition by Id
        app.delete '/definitions/:id', :provides => [:json] do
          @definition = Definition.first(:id => params['id'])

          protected! if @definition.domain
          protected! app.to_entity_admins(@definition.entity) if @definition.entity

          @definition.datums_dataset.destroy
          @definition.blueprints_dataset.destroy
          @definition.destroy

          204
        end

      end
    end
  end
end
