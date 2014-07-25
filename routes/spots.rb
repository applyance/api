module Applyance
  module Routing
    module Spots

      module Protection

        # Protection to full access reviewers
        def to_full_access_reviewers(unit)
          lambda do |account|
            unit.reviewers_dataset.where(:access_level => ["admin", "full"]).collect(&:account_id).include?(account.id)
          end
        end

      end

      def self.registered(app)

        app.extend(Applyance::Routing::Spots::Protection)

        # List spots
        app.get '/units/:id/spots', :provides => [:json] do
          @unit = Unit.first(:id => params['id'])
          @spots = @unit.spots
          rabl :'spots/index'
        end

        # Create a new unit
        # Must be a full access reviewer
        app.post '/units/:id/spots', :provides => [:json] do
          @unit = Unit.first(:id => params['id'])
          protected! app.to_full_access_reviewers(@unit)

          @spot = Spot.new
          @spot.set(:unit_id => @unit.id)
          @spot.set_fields(params, ['name', 'detail', 'status'], :missing => :skip)
          @spot.save

          status 201
          rabl :'spots/show'
        end

        # Get spot by Id
        app.get '/spots/:id', :provides => [:json] do
          @spot = Spot.first(:id => params['id'])
          rabl :'spots/show'
        end

        # Update a spot by Id
        # Must be a full access reviewer
        app.put '/spots/:id', :provides => [:json] do
          @spot = Spot.first(:id => params['id'])
          protected! app.to_full_access_reviewers(@spot.unit)

          @spot.update_fields(params, ['name', 'detail', 'status'], :missing => :skip)
          rabl :'spots/show'
        end

        # Delete a entity by Id
        # Must be a full access reviewer
        app.delete '/spots/:id', :provides => [:json] do
          @spot = Spot.first(:id => params['id'])
          protected! app.to_full_access_reviewers(@spot.unit)

          @spot.ratings_dataset.destroy
          @spot.remove_all_blueprints
          @spot.destroy

          204
        end

      end
    end
  end
end
