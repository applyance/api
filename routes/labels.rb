module Applyance
  module Routing
    module Labels

      module Protection
        # General protection function for reviewers
        def to_full_access_reviewers(unit)
          lambda do |account|
            unit.reviewers_dataset.where(:access_level => ["admin", "full"]).collect(&:account_id).include?(account.id)
          end
        end

        def to_reviewers(unit)
          lambda do |account|
            unit.reviewers.collect(&:account_id).include?(account.id)
          end
        end
      end

      def self.registered(app)

        app.extend(Applyance::Routing::Labels::Protection)

        # List labels by unit
        # Only reviewers can do this
        app.get '/units/:id/labels', :provides => [:json] do
          @unit = Unit.first(:id => params[:id])
          protected! app.to_reviewers(@unit)
          @labels = @unit.labels
          rabl :'labels/index'
        end

        # Create a new label
        # Must be a full reviewer
        app.post '/units/:id/labels', :provides => [:json] do
          @unit = Unit.first(:id => params[:id])
          protected! app.to_full_access_reviewers(@unit)

          @label = Label.new
          @label.set(:unit_id => @unit.id)
          @label.set_fields(params, ['name', 'color'], :missing => :skip)
          @label.save

          status 201
          rabl :'labels/show'
        end

        # Get label by Id
        app.get '/labels/:id', :provides => [:json] do
          @label = Label.first(:id => params['id'])
          protected! app.to_reviewers(@label.unit)

          rabl :'labels/show'
        end

        # Update a pipeline by Id
        # Must be a full reviewer
        app.put '/labels/:id', :provides => [:json] do
          @label = Label.first(:id => params['id'])
          protected! app.to_full_access_reviewers(@label.unit)

          @label.update_fields(params, ['name', 'color'], :missing => :skip)
          rabl :'labels/show'
        end

        # Delete a label by Id
        # Must be a full reviewer
        app.delete '/labels/:id', :provides => [:json] do
          @label = Label.first(:id => params['id'])
          protected! app.to_full_access_reviewers(@label.unit)

          @label.destroy

          204
        end

      end
    end
  end
end
