module Applyance
  module Routing
    module Reviewers

      module Protection
        # General protection function for entity reviewers
        def to_reviewers(entity)
          lambda { |account| entity.reviewers.collect(&:account_id).include?(account.id) }
        end
      end

      def self.registered(app)

        app.extend(Applyance::Routing::Reviewers::Protection)

        # List reviewers for an entity
        app.get '/entities/:id/reviewers', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          protected! app.to_reviewers(@entity)
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
          @reviewer = Reviewer.find_or_create(
            :entity_id => @entity.id,
            :account_id => account.id
          )
          @reviewer.update(:scope => "admin")

          @reviewer.send_welcome_email

          status 201
          rabl :'reviewers/show'
        end

        # Get reviewer by Id
        app.get '/reviewers/:id', :provides => [:json] do
          @reviewer = Reviewer.first(:id => params['id'])
          protected! app.to_reviewers(@reviewer.entity)
          rabl :'reviewers/show'
        end

        # Update reviewer by Id
        app.put '/reviewers/:id', :provides => [:json] do
          @reviewer = Reviewer.first(:id => params['id'])
          protected! app.to_reviewers(@reviewer)
          @reviewer.update_fields(params, ['scope'], :missing => :skip)
          rabl :'reviewers/show'
        end

        # Delete an reviewer by Id
        app.delete '/reviewers/:id', :provides => [:json] do
          @reviewer = Reviewer.first(:id => params['id'])
          protected! app.to_reviewers(@reviewer.entity)

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
