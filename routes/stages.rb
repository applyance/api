module Applyance
  module Routing
    module Stages

      def self.registered(app)

        # List stages by pipeline
        # Only reviewers can do this
        app.get '/pipelines/:id/stages', :provides => [:json] do
          @pipeline = Pipeline.first(:id => params[:id])
          protected! app.to_entity_reviewers(@pipeline.entity)
          @stages = @pipeline.stages
          rabl :'stages/index'
        end

        # Create a new stage
        # Must be a full reviewer
        app.post '/pipelines/:id/stages', :provides => [:json] do
          @pipeline = Pipeline.first(:id => params[:id])
          protected! app.to_entity_admins(@pipeline.entity)

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
          protected! app.to_entity_reviewers(@stage.pipeline.entity)

          rabl :'stages/show'
        end

        # Update a stage by Id
        # Must be a full reviewer
        app.put '/stages/:id', :provides => [:json] do
          @stage = Stage.first(:id => params['id'])
          protected! app.to_entity_admins(@stage.pipeline.entity)

          @stage.update_fields(params, ['name', 'position'], :missing => :skip)
          rabl :'stages/show'
        end

        # Delete a stage by Id
        # Must be a full reviewer
        app.delete '/stages/:id', :provides => [:json] do
          @stage = Stage.first(:id => params['id'])
          protected! app.to_entity_admins(@stage.pipeline.entity)

          @stage.remove_all_citizens
          @stage.destroy

          204
        end

      end
    end
  end
end
