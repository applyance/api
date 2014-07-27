module Applyance
  module Routing
    module Units

      module Protection

        def to_admins(entity)
          lambda { |account| entity.admins.collect(&:account_id).include?(account.id) }
        end

        def to_full_access_reviewers(unit)
          lambda do |account|
            unit.reviewers_dataset.where(:access_level => ["admin", "full"]).collect(&:account_id).include?(account.id)
          end
        end

      end

      def self.registered(app)

        app.extend(Applyance::Routing::Units::Protection)

        # List units
        # Only entity admins can do this
        app.get '/entities/:id/units', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          protected! app.to_admins(@entity)

          @units = @entity.units
          rabl :'units/index'
        end

        # Create a new unit
        # Only entity admins can do this
        app.post '/entities/:id/units', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          protected! app.to_admins(@entity)

          @unit = Unit.new
          @unit.set_fields(params, ['name'], :missing => :skip)
          @unit.set(:entity_id => @entity.id)
          @unit.save
          @unit.attach(params['logo'], :logo)

          status 201
          rabl :'units/show'
        end

        # Get unit by Id
        app.get '/units/:id', :provides => [:json] do
          @unit = Unit.first(:id => params['id'])
          rabl :'units/show'
        end

        # Update a unit by Id
        # Must be an admin
        app.put '/units/:id', :provides => [:json] do
          @unit = Unit.first(:id => params['id'])
          @account = protected! app.to_admins(@unit.entity)

          @unit.update_fields(params, ['name'], :missing => :skip)
          @unit.attach(params['logo'], :logo)
          
          rabl :'units/show'
        end

        # Delete a unit by Id
        # Must be an admin
        app.delete '/units/:id', :provides => [:json] do
          @unit = Unit.first(:id => params['id'])
          protected! app.to_full_access_reviewers(@unit)

          @unit.reviewers_dataset.destroy
          @unit.reviewer_invites_dataset.destroy
          @unit.spots_dataset.destroy
          @unit.templates_dataset.destroy
          @unit.pipelines_dataset.destroy
          @unit.labels_dataset.destroy
          @unit.definitions_dataset.destroy
          @unit.remove_all_blueprints
          @unit.destroy

          204
        end

      end
    end
  end
end
