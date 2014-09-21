module Applyance
  module Routing
    module Citizens

      def self.registered(app)

        # Return all citizens
        # (for administrative purposes)
        app.get '/citizens' do
          protected!
          @citizens = Citizen.all
          rabl :'citizens/index'
        end

        # Get citizens of entity
        # Must be a reviewer
        app.get '/entities/:id/citizens' do
          @entity = Entity.first(:id => params['id'])
          if @entity.nil?
            raise BadRequestError.new({ detail: "Entity doesn't exist." })
          end
          protected! app.to_entity_reviewers(@entity)
          paywall! @entity, 'applicantList'

          @citizens = @entity.get_citizens
          rabl :'citizens/index'
        end

        # Get citizens of a spot
        # Must be a reviewer
        app.get '/spots/:id/citizens' do
          @spot = Spot.first(:id => params['id'])
          if @spot.nil?
            raise BadRequestError.new({ detail: "Spot doesn't exist." })
          end
          protected! app.to_entity_reviewers(@spot.entity)
          paywall! @spot.entity, 'applicantList'

          @citizens = @spot.get_citizens
          rabl :'citizens/index'
        end

        # Get citizen by Id
        # Must be a reviewer or citizen owner
        app.get '/citizens/:id', :provides => [:json] do
          @citizen = Citizen.first(:id => params['id'])
          if @citizen.nil?
            raise BadRequestError.new({ detail: "Citizen doesn't exist." })
          end
          protected! app.to_citizen_reviewers_or_self(@citizen)
          rabl :'citizens/show'
        end

        # Update a citizen by Id
        app.put '/citizens/:id', :provides => [:json] do
          @citizen = Citizen.first(:id => params['id'])
          protected! app.to_citizen_reviewers_or_self(@citizen)

          @citizen.update_fields(params, ['stage_id'], :missing => :skip)

          # Update labels
          unless params['label_ids'].nil?
            @citizen.remove_all_labels
            params['label_ids'].each do |label_id|
              @citizen.add_label(Label.first(:id => label_id))
            end
          end

          rabl :'citizens/show'
        end

        # Delete a citizen by Id
        # Must be the citizen owner
        app.delete '/citizens/:id', :provides => [:json] do
          @citizen = Citizen.first(:id => params['id'])
          protected! app.to_account_id(@citizen.account_id)

          @citizen.remove_all_labels

          @citizen.activities_dataset.destroy
          @citizen.threads_dataset.destroy
          @citizen.ratings_dataset.destroy
          @citizen.applications_dataset.destroy

          @citizen.destroy

          204
        end

      end
    end
  end
end
