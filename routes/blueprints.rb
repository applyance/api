module Applyance
  module Routing
    module Blueprints

      module Protection
        # Protection to full access reviewers
        def to_reviewers(entity)
          lambda do |account|
            entity.reviewers.collect(&:account_id).include?(account.id)
          end
        end

        # Protection to admins
        def to_admins(entity)
          lambda do |account|
            entity.reviewers_dataset.where(:scope => "admin").collect(&:account_id).include?(account.id)
          end
        end
      end

      def self.registered(app)

        app.extend(Applyance::Routing::Blueprints::Protection)

        # List blueprints for spot
        # Must be a full-access reviewer
        app.get '/spots/:id/blueprints', :provides => [:json] do
          @spot = Spot.first(:id => params['id'])
          @blueprints = @spot.blueprints
          rabl :'blueprints/index'
        end

        # List blueprints for entity
        # Must be an admin
        app.get '/entities/:id/blueprints', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          @blueprints = @entity.blueprints
          rabl :'blueprints/index'
        end

        # Create a new blueprint for a spot
        # Must be a full-access reviewer
        app.post '/spots/:id/blueprints', :provides => [:json] do
          @spot = Spot.first(:id => params['id'])
          protected! app.to_reviewers(@spot.entity)

          @blueprint = Blueprint.new
          @blueprint.set_fields(params, ['definition_id', 'position', 'is_required'], :missing => :skip)
          @blueprint.save
          @spot.add_blueprint(@blueprint)

          status 201
          rabl :'blueprints/show'
        end

        # Create a new blueprint for a spot
        # Must be an admin
        app.post '/entities/:id/blueprints', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          protected! app.to_admins(@entity)

          @blueprint = Blueprint.new
          @blueprint.set_fields(params, ['definition_id', 'position', 'is_required'], :missing => :skip)
          @blueprint.save
          @entity.add_blueprint(@blueprint)

          status 201
          rabl :'blueprints/show'
        end

        # Get blueprint by Id
        app.get '/blueprints/:id', :provides => [:json] do
          @blueprint = Blueprint.first(:id => params['id'])
          rabl :'blueprints/show'
        end

        # Update a blueprint by Id
        app.put '/blueprints/:id', :provides => [:json] do
          @blueprint = Blueprint.first(:id => params['id'])

          protected! app.to_admins(@blueprint.spot.entity) if @blueprint.spot
          protected! app.to_admins(@blueprint.entity) if @blueprint.entity

          @blueprint.update_fields(params, ['position', 'is_required'], :missing => :skip)
          rabl :'blueprints/show'
        end

        # Delete a blueprint by Id
        app.delete '/blueprints/:id', :provides => [:json] do
          @blueprint = Blueprint.first(:id => params['id'])

          protected! app.to_admins(@blueprint.spot.entity) if @blueprint.spot
          protected! app.to_admins(@blueprint.entity) if @blueprint.entity

          @blueprint.destroy

          204
        end

      end
    end
  end
end
