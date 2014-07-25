module Applyance
  module Routing
    module Definitions

      module Protection

        # Protection to full access reviewers
        def to_full_access_reviewers(unit)
          lambda do |account|
            unit.reviewers_dataset.where(:access_level => ["admin", "full"]).collect(&:account_id).include?(account.id)
          end
        end

      end

      def self.registered(app)

        app.extend(Applyance::Routing::Definitions::Protection)

        # List definitions for unit
        # Must be a full-access reviewer
        app.get '/units/:id/definitions', :provides => [:json] do
          @unit = Unit.first(:id => params['id'])
          protected! app.to_full_access_reviewers(@unit)
          @definitions = @unit.definitions
          rabl :'definitions/index'
        end

        # List definitions for domain
        app.get '/domains/:id/definitions', :provides => [:json] do
          @domain = Domain.first(:id => params['id'])
          @definitions = @domain.definitions
          rabl :'definitions/index'
        end

        # Create a new definition
        # Must be a full access reviewer
        app.post '/units/:id/definitions', :provides => [:json] do
          @unit = Unit.first(:id => params['id'])
          protected! app.to_full_access_reviewers(@unit)

          @definition = Definition.new
          @definition.set_fields(params, ['label', 'description', 'type', 'helper'], :missing => :skip)
          @definition.save

          @unit.add_definition(@definition)

          status 201
          rabl :'definitions/show'
        end

        # Create a new definition
        # Must be a chief B)
        app.post '/domains/:id/definitions', :provides => [:json] do
          protected!

          @domain = Domain.first(:id => params['id'])

          @definition = Definition.new
          @definition.set_fields(params, ['label', 'description', 'type', 'helper'], :missing => :skip)
          @definition.save

          @domain.add_definition(@definition)

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
          protected! app.to_full_access_reviewers(@definition.unit) if @definition.unit

          @definition.update_fields(params, ['label', 'description', 'type', 'helper'], :missing => :skip)
          rabl :'definitions/show'
        end

        # Delete a definition by Id
        app.delete '/definitions/:id', :provides => [:json] do
          @definition = Definition.first(:id => params['id'])

          protected! if @definition.domain
          protected! app.to_full_access_reviewers(@definition.unit) if @definition.unit

          @definition.datums_dataset.destroy
          @definition.blueprints_dataset.destroy
          @definition.destroy

          204
        end

      end
    end
  end
end
