module Applyance
  module Routing
    module Citizens

      def self.registered(app)

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

          @citizen.threads_dataset.destroy
          @citizen.ratings_dataset.destroy
          @citizen.datums_dataset.destroy
          @citizen.applications_dataset.destroy

          @citizen.destroy

          204
        end

      end
    end
  end
end
