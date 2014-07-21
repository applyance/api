module Applyance
  module Routing
    module AdminInvites

      module Protection
        # General protection function for entity admins
        def to_admins(entity)
          lambda { |account| entity.admins.collect(&:account_id).include?(account.id) }
        end
      end

      def self.registered(app)

        app.extend(Applyance::Routing::AdminInvites::Protection)

        # List admin invites
        app.get '/entities/:id/admins/invites', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          protected! app.to_admins(@entity)

          @admin_invites = @entity.admin_invites
          rabl :'admin_invites/index'
        end

        # Create a new admin invite
        app.post '/entities/:id/admins/invites', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          protected! app.to_admins(@entity)

          @admin_invite = AdminInvite.make(@entity, params)

          status 201
          rabl :'admin_invites/show'
        end

        # Get admin invite by Id
        app.get '/admins/invites/:id', :provides => [:json] do
          @admin_invite = AdminInvite.first(:id => params['id'])
          protected! app.to_admins(@admin_invite.entity)
          rabl :'admin_invites/show'
        end

        # Claim an admin invite
        app.put '/admins/invites/:id', :provides => [:json] do
          @admin_invite = AdminInvite.first(:claim_digest => params['claim_digest'])

          unless @admin_invite
            raise BadRequestError({ :detail => "Must send a valid claim digest." })
          end

          @admin = @admin_invite.claim(params)
          rabl :'admins/show'
        end

      end
    end
  end
end
