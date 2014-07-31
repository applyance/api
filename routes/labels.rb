module Applyance
  module Routing
    module Labels

      module Protection
        # General protection for admins
        def to_admins(entity)
          lambda do |account|
            entity.reviewers_dataset.where(:scope => "admin").collect(&:account_id).include?(account.id)
          end
        end

        def to_reviewers(entity)
          lambda do |account|
            entity.reviewers.collect(&:account_id).include?(account.id)
          end
        end
      end

      def self.registered(app)

        app.extend(Applyance::Routing::Labels::Protection)

        # List labels by entity
        # Only reviewers can do this
        app.get '/entities/:id/labels', :provides => [:json] do
          @entity = Entity.first(:id => params[:id])
          protected! app.to_reviewers(@entity)
          @labels = @entity.labels
          rabl :'labels/index'
        end

        # Create a new label
        # Must be an admin
        app.post '/entities/:id/labels', :provides => [:json] do
          @entity = Entity.first(:id => params[:id])
          protected! app.to_admins(@entity)

          @label = Label.new
          @label.set(:entity_id => @entity.id)
          @label.set_fields(params, ['name', 'color'], :missing => :skip)
          @label.save

          status 201
          rabl :'labels/show'
        end

        # Get label by Id
        app.get '/labels/:id', :provides => [:json] do
          @label = Label.first(:id => params['id'])
          protected! app.to_reviewers(@label.entity)

          rabl :'labels/show'
        end

        # Update a label by Id
        # Must be an admin
        app.put '/labels/:id', :provides => [:json] do
          @label = Label.first(:id => params['id'])
          protected! app.to_admins(@label.entity)

          @label.update_fields(params, ['name', 'color'], :missing => :skip)
          rabl :'labels/show'
        end

        # Delete a label by Id
        # Must be an admin
        app.delete '/labels/:id', :provides => [:json] do
          @label = Label.first(:id => params['id'])
          protected! app.to_admins(@label.entity)

          @label.destroy

          204
        end

      end
    end
  end
end
