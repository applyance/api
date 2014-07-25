module Applyance
  module Routing
    module Stages

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

        app.extend(Applyance::Routing::Stages::Protection)

        # List stages by pipeline
        # Only reviewers can do this
        app.get '/pipelines/:id/stages', :provides => [:json] do
          @pipeline = Pipeline.first(:id => params[:id])
          protected! app.to_reviewers(@pipeline.unit)
          @stages = @pipeline.stages
          rabl :'stages/index'
        end

        # Create a new stage
        # Must be a full reviewer
        app.post '/pipelines/:id/stages', :provides => [:json] do
          @pipeline = Pipeline.first(:id => params[:id])
          protected! app.to_full_access_reviewers(@pipeline.unit)

          @stage = Stage.new
          @stage.set(:pipeline_id => @pipeline.id)
          @stage.set_fields(params, ['name', 'position'], :missing => :skip)
          @stage.save

          status 201
          rabl :'stages/show'
        end

        # Get stage by Id
        app.get '/stages/:id', :provides => [:json] do
          @stage = Stage.first(:id => params['id'])
          protected! app.to_reviewers(@stage.pipeline.unit)

          rabl :'stages/show'
        end

        # Update a stage by Id
        # Must be a full reviewer
        app.put '/stages/:id', :provides => [:json] do
          @stage = Stage.first(:id => params['id'])
          protected! app.to_full_access_reviewers(@stage.pipeline.unit)

          @stage.update_fields(params, ['name', 'position'], :missing => :skip)
          rabl :'stages/show'
        end

        # Delete a stage by Id
        # Must be a full reviewer
        app.delete '/stages/:id', :provides => [:json] do
          @stage = Stage.first(:id => params['id'])
          protected! app.to_full_access_reviewers(@stage.pipeline.unit)

          @stage.remove_all_applications
          @stage.destroy

          204
        end

      end
    end
  end
end
