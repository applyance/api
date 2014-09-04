module Applyance
  module Routing
    module Reviewers

      def self.registered(app)

        # List reviewers for an entity
        app.get '/entities/:id/reviewers', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          protected! app.to_entity_reviewers(@entity)
          @reviewers = @entity.reviewers
          rabl :'reviewers/index'
        end

        # Create reviewer for entity
        app.post '/entities/:id/reviewers', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          if @entity.nil?
            raise BadRequestError.new({ :detail => "Must be a valid entity." })
          end

          account = Account.make("reviewer", params)
          reviewer = Reviewer.first(:entity_id => @entity.id, :account_id => account.id)

          if reviewer
            raise BadRequestError.new({ :detail => "You are already a reviewer at this entity." })
          end

          @reviewer = Reviewer.create(
            :entity_id => @entity.id,
            :account_id => account.id,
            :scope => "admin"
          )

          @reviewer.send_welcome_email
          @reviewer.subscribe_to_mailchimp

          status 201
          rabl :'reviewers/show'
        end

        # Get reviewer by Id
        app.get '/reviewers/:id', :provides => [:json] do
          @reviewer = Reviewer.first(:id => params['id'])
          protected! app.to_entity_reviewers(@reviewer.entity)
          rabl :'reviewers/show'
        end

        # Update reviewer by Id
        app.put '/reviewers/:id', :provides => [:json] do
          @reviewer = Reviewer.first(:id => params['id'])
          protected! app.to_entity_admins(@reviewer.entity)
          @reviewer.update_fields(params, ['scope'], :missing => :skip)
          rabl :'reviewers/show'
        end

        # Delete an reviewer by Id
        app.delete '/reviewers/:id', :provides => [:json] do
          @reviewer = Reviewer.first(:id => params['id'])
          protected! app.to_entity_admins(@reviewer.entity)

          if @reviewer.entity.reviewers.length == 1
            raise BadRequestError.new({ :detail => "Cannot remove last reviewer from entity." })
          end

          @reviewer.destroy

          204
        end

      end
    end
  end
end
