module Applyance
  module Routing
    module Definitions

      def self.registered(app)

        # List all public definitions
        app.get '/definitions', :provides => [:json] do
          @definitions = Definition.exclude(
            :id => app.db[:definitions_entities].select(:definition_id)).by_default_position
          rabl :'definitions/index'
        end

        # List definitions for entity
        # Must be an admin
        app.get '/entities/:id/definitions', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          protected! app.to_entity_admins(@entity)
          @definitions = @entity.definitions_dataset.by_default_position
          rabl :'definitions/index'
        end

        # List definitions for domain
        app.get '/domains/:id/definitions', :provides => [:json] do
          entity_definitions = app.db[:definitions_entities].map(:definition_id)
          domain_query = app.db[:definitions_domains].where(Sequel.~(:domain_id => params['id']))
          domain_definitions = domain_query.map(:definition_id)
          to_exclude = entity_definitions + domain_definitions
          @definitions = Definition.exclude(:id => to_exclude).by_default_position
          rabl :'definitions/index'
        end

        # Create a new definition
        # Must be an admin
        app.post '/entities/:id/definitions', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          protected! app.to_entity_admins(@entity)
          paywall! @entity, 'questions'

          unless @entity.definitions.count < 5
            raise BadRequestError.new({ detail: "Entities can only have 5 definitions." })
          end

          @definition = Definition.new
          @definition.set_fields(params, ['name', 'label', 'description', 'is_core', 'is_default', 'default_is_required', 'default_position', 'placeholder', 'type', 'helper'], :missing => :skip)
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
          @definition.set_fields(params, ['name', 'label', 'description', 'is_core', 'is_default', 'default_is_required', 'default_position', 'placeholder', 'type', 'helper'], :missing => :skip)
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
          @definition.set_fields(params, ['name', 'label', 'description', 'is_core', 'is_default', 'default_is_required', 'default_position', 'placeholder', 'type', 'helper'], :missing => :skip)
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

          paywall! @definition.entity, 'questions' if @definition.entity

          # Update or remove the domain, if applicable
          if params['domain_id']
            if @definition.domain
              @definition.domain.remove_definition(@definition)
            end
            unless params['domain_id'] == -1
              @domain = Domain.first(:id => params['domain_id'])
              @domain.add_definition(@definition)
            end
          end

          @definition.update_fields(params, ['name', 'label', 'description', 'is_core', 'is_default', 'default_is_required', 'default_position', 'placeholder', 'type', 'helper'], :missing => :skip)

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
