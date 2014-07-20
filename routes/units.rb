module Applyance
  module Routing
    module Units
      def self.registered(app)

        # General protection function for entity admins
        to_admins = lambda do |entity|
          lambda { |account| entity.admins.collect(&:account_id).include?(account.id) }
        end

        # Protection to admins or reviewers
        to_admins_or_reviewers = lambda do |unit|
          lambda do |account|
            return true if unit.entity.admins.collect(&:account_id).include?(account.id)
            unit.reviewers_dataset.where(:access_level => "full").collect(&:account_id).include?(account.id)
          end
        end

        # List units
        # Only entity admins can do this
        app.get '/entities/:id/units', :provides => [:json] do
          @entity = Entity.first(:id => params[:id])
          protected! to_admins(@entity)

          @units = @entity.units
          rabl :'units/index'
        end

        # Create a new unit
        # Only entity admins can do this
        app.post '/entities/:id/units', :provides => [:json] do
          @entity = Entity.first(:id => params[:id])
          protected! to_admins(@entity)

          @unit = Unit.new
          @unit.set_fields(params, [:name], :missing => :skip)
          @unit.set(:entity_id => @entity.id)
          @unit.save

          status 201
          rabl :'units/show'
        end

        # Get unit by Id
        app.get '/units/:id', :provides => [:json] do
          @unit = Unit.first(:id => params[:id])
          rabl :'units/show'
        end

        # Update a unit by Id
        # Must be an admin
        app.put '/units/:id', :provides => [:json] do
          @unit = Unit.first(:id => params[:id])
          @account = protected! to_admins_or_reviewers(@unit)

          @unit.update_fields(params, [:name], :missing => :skip)
          rabl :'units/show'
        end

        # Delete a unit by Id
        # Must be an admin
        app.delete '/units/:id', :provides => [:json] do
          @unit = Unit.first(:id => params[:id])
          protected! to_admins_or_reviewers(@unit)

          @unit.reviewers_dataset.destroy
          @unit.reviewer_invites_dataset.destroy
          @unit.spots_dataset.destroy
          @unit.templates_dataset.destroy
          @unit.pipelines_dataset.destroy
          @unit.labels_dataset.destroy
          @unit.definitions_dataset.destroy
          @unit.destroy

          204
        end

      end
    end
  end
end
