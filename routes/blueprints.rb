module Applyance
  module Routing
    module Blueprints
      def self.registered(app)

        # Protection to full access reviewers
        to_full_access_reviewers = lambda do |unit|
          lambda do |account|
            unit.reviewers_dataset.where(:access_level => "full").collect(&:account_id).include?(account.id)
          end
        end

        # List blueprints for unit
        # Must be a full-access reviewer
        app.get '/units/:id/blueprints', :provides => [:json] do
          @unit = Unit.first(:id => params[:id])
          protected! to_full_access_reviewers(@unit)
          @blueprints = @unit.blueprints
          rabl :'blueprints/index'
        end

        # List blueprints for spot
        # Must be a full-access reviewer
        app.get '/spots/:id/blueprints', :provides => [:json] do
          @spot = Spot.first(:id => params[:id])
          protected! to_full_access_reviewers(@spot.unit)
          @blueprints = @spot.blueprints
          rabl :'blueprints/index'
        end

        # Create a new blueprint for a unit
        # Must be a full-access reviewer
        app.post '/units/:id/blueprints', :provides => [:json] do
          @unit = Unit.first(:id => params[:id])
          protected! to_full_access_reviewers(@unit)

          @blueprint = Blueprint.new
          @blueprint.set_fields(params, [:definition_id, :position, :is_required], :missing => :skip)
          @blueprint.add_unit(@unit)
          @blueprint.save

          status 201
          rabl :'definitions/show'
        end

        # Create a new blueprint for a spot
        # Must be a full-access reviewer
        app.post '/spots/:id/blueprints', :provides => [:json] do
          @spot = Spot.first(:id => params[:id])
          protected! to_full_access_reviewers(@spot.unit)

          @blueprint = Blueprint.new
          @blueprint.set_fields(params, [:definition_id, :position, :is_required], :missing => :skip)
          @blueprint.add_spot(@spot)
          @blueprint.save

          status 201
          rabl :'definitions/show'
        end

        # Get blueprint by Id
        app.get '/blueprints/:id', :provides => [:json] do
          @blueprint = Blueprint.first(:id => params[:id])
          rabl :'blueprints/show'
        end

        # Update a blueprint by Id
        app.put '/blueprints/:id', :provides => [:json] do
          @blueprint = Blueprint.first(:id => params[:id])

          protected! to_full_access_reviewers(@blueprint.spot.unit) if @blueprint.spot
          protected! to_full_access_reviewers(@blueprint.unit) if @blueprint.unit

          @blueprint.update_fields(params, [:definition_id, :position, :is_required], :missing => :skip)
          rabl :'blueprints/show'
        end

        # Delete a blueprint by Id
        app.delete '/blueprints/:id', :provides => [:json] do
          @blueprint = Blueprint.first(:id => params[:id])

          protected! to_full_access_reviewers(@blueprint.spot.unit) if @blueprint.spot
          protected! to_full_access_reviewers(@blueprint.unit) if @blueprint.unit

          @blueprint.remove_all_spots
          @blueprint.remove_all_units
          @blueprint.destroy

          204
        end

      end
    end
  end
end
