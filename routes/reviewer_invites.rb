module Applyance
  module Routing
    module ReviewerInvites

      def self.registered(app)

        # List reviewer invites
        app.get '/entities/:id/reviewers/invites', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          protected! app.to_entity_reviewers(@entity)

          @reviewer_invites = @entity.reviewer_invites
          rabl :'reviewer_invites/index'
        end

        # Create a new reviewer invite
        app.post '/entities/:id/reviewers/invites', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          protected! app.to_entity_reviewers(@entity)

          @reviewer_invite = ReviewerInvite.make(@entity, params)
          @reviewer_invite.send_claim_email

          status 201
          rabl :'reviewer_invites/show'
        end

        # Get reviewer invite by Id
        app.get '/reviewers/invites/:id', :provides => [:json] do
          @reviewer_invite = ReviewerInvite.first(:id => params['id'])
          protected! app.to_entity_reviewers(@reviewer_invite.entity)
          rabl :'reviewer_invites/show'
        end

        # Claim an reviewer invite
        app.post '/reviewers/invites/claim', :provides => [:json] do
          @reviewer_invite = ReviewerInvite.first(:claim_digest => params['claim_digest'])

          unless @reviewer_invite
            raise BadRequestError({ :detail => "Must send a valid claim digest." })
          end

          @reviewer = @reviewer_invite.claim(params)
          rabl :'reviewers/show'
        end

      end
    end
  end
end
