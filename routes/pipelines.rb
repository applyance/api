module Applyance
  module Routing
    module Pipelines

      module Protection
        # General protection function for reviewers
        def to_admins(entity)
          lambda do |account|
            entity.reviewers_dataset.where(:scope => "admin").collect(&:account_id).include?(account.id)
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

        # List pipelines for entities
        # Only reviewers can do this
        app.get '/entities/:id/pipelines', :provides => [:json] do
          @entity = Entity.first(:id => params[:id])
          protected! app.to_reviewers(@entity)
          @pipelines = @entity.pipelines
          rabl :'pipelines/index'
        end

        # Create a new pipeline
        # Must be an admin
        app.post '/entities/:id/pipelines', :provides => [:json] do
          @entity = Entity.first(:id => params[:id])
          protected! app.to_admins(@entity)

          @pipeline = Pipeline.new
          @pipeline.set(:entity_id => @entity.id)
          @pipeline.set_fields(params, ['name'], :missing => :skip)
          @pipeline.save

          status 201
          rabl :'pipelines/show'
        end

        # Get pipeline by Id
        app.get '/pipelines/:id', :provides => [:json] do
          @pipeline = Pipeline.first(:id => params['id'])
          protected! app.to_reviewers(@pipeline.entity)

          rabl :'pipelines/show'
        end

        # Update a pipeline by Id
        # Must be an admin
        app.put '/pipelines/:id', :provides => [:json] do
          @pipeline = Pipeline.first(:id => params['id'])
          protected! app.to_admins(@pipeline.entity)

          @pipeline.update_fields(params, ['name'], :missing => :skip)
          rabl :'pipelines/show'
        end

        # Delete a pipeline by Id
        # Must be an admin
        app.delete '/pipelines/:id', :provides => [:json] do
          @pipeline = Pipeline.first(:id => params['id'])
          protected! app.to_admins(@pipeline.entity)

          @pipeline.stages_dataset.destroy
          @pipeline.destroy

          204
        end

      end
    end
  end
end
