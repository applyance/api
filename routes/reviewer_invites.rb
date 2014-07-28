module Applyance
  module Routing
    module ReviewerInvites

      module Protection

        # Protection to admins or reviewers
        def to_full_access_reviewers(unit)
          lambda do |account|
            unit.reviewers_dataset.where(:access_level => ["admin", "full"]).collect(&:account_id).include?(account.id)
          end
        end

      end

      def self.registered(app)

        app.extend(Applyance::Routing::ReviewerInvites::Protection)

        # List reviewer invites
        app.get '/units/:id/reviewers/invites', :provides => [:json] do
          @unit = Unit.first(:id => params['id'])
          protected! app.to_full_access_reviewers(@unit)

          @reviewer_invites = @unit.reviewer_invites
          rabl :'reviewer_invites/index'
        end

        # Create a new reviewer invite
        app.post '/units/:id/reviewers/invites', :provides => [:json] do
          @unit = Unit.first(:id => params['id'])
          protected! app.to_full_access_reviewers(@unit)

          @reviewer_invite = ReviewerInvite.make(@unit, params)
          @reviewer_invite.send_claim_email

          status 201
          rabl :'reviewer_invites/show'
        end

        # Get reviewer invite by Id
        app.get '/reviewers/invites/:id', :provides => [:json] do
          @reviewer_invite = ReviewerInvite.first(:id => params['id'])
          protected! app.to_full_access_reviewers(@reviewer_invite.unit)
          rabl :'reviewer_invites/show'
        end

        # Claim a reviewer invite
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
