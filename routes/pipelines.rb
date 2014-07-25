module Applyance
  module Routing
    module Pipelines

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

        app.extend(Applyance::Routing::Pipelines::Protection)

        # List pipelines by unit
        # Only reviewers can do this
        app.get '/units/:id/pipelines', :provides => [:json] do
          @unit = Unit.first(:id => params[:id])
          protected! app.to_reviewers(@unit)
          @pipelines = @unit.pipelines
          rabl :'pipelines/index'
        end

        # Create a new pipeline
        # Must be a full reviewer
        app.post '/units/:id/pipelines', :provides => [:json] do
          @unit = Unit.first(:id => params[:id])
          protected! app.to_full_access_reviewers(@unit)

          @pipeline = Pipeline.new
          @pipeline.set(:unit_id => @unit.id)
          @pipeline.set_fields(params, ['name'], :missing => :skip)
          @pipeline.save

          status 201
          rabl :'pipelines/show'
        end

        # Get pipeline by Id
        app.get '/pipelines/:id', :provides => [:json] do
          @pipeline = Pipeline.first(:id => params['id'])
          protected! app.to_reviewers(@pipeline.unit)

          rabl :'pipelines/show'
        end

        # Update a pipeline by Id
        # Must be a full reviewer
        app.put '/pipelines/:id', :provides => [:json] do
          @pipeline = Pipeline.first(:id => params['id'])
          protected! app.to_full_access_reviewers(@pipeline.unit)

          @pipeline.update_fields(params, ['name'], :missing => :skip)
          rabl :'pipelines/show'
        end

        # Delete a pipeline by Id
        # Must be a full reviewer
        app.delete '/pipelines/:id', :provides => [:json] do
          @pipeline = Pipeline.first(:id => params['id'])
          protected! app.to_full_access_reviewers(@pipeline.unit)

          @pipeline.stages_dataset.destroy
          @pipeline.destroy

          204
        end

      end
    end
  end
end
