module Applyance
  module Routing
    module Accounts
      def self.registered(app)

        # Register an account as a reviewer
        app.post '/reviewers/register', :provides => [:json] do
          @account = Account.register("reviewer", params)
          @entity = Entity.register(@account, params)
          status 201
          rabl :'accounts/reviewers/create'
        end

        # Show an account specified by Id
        app.get '/accounts/:id', :provides => [:json] do
          @account = protected!(lambda { |account| account.pk == params[:id].to_i })
          rabl :'accounts/show'
        end

        # Update an account specified by Id
        app.put '/accounts/:id', :provides => [:json] do
          @account = protected!(lambda { |account| account.pk == params[:id].to_i })
          @account.update(params.slice(:name))
          rable :'accounts/show'
        end

        # Reset password
        app.post '/accounts/:id/reset-password', :provides => [:json] do
          @account = Account.first(:email => params[:email])
          unless @account
            raise BadRequestError({ detail: "An account with that email does not exist." })
          end
          @account.reset_password(params)
          201
        end

        # Change password
        app.post '/accounts/:id/change-password', :provides => [:json] do
          @account = protected!(lambda { |account| account.pk == params[:id].to_i })
          @account.change_password(params)
          rabl :'accounts/show'
        end

        # Change email address
        app.post '/accounts/:id/change-email', :provides => [:json] do
          @account = protected!(lambda { |account| account.pk == params[:id].to_i })
          @account.change_email(params)
          rabl :'accounts/show'
        end

        # Verify email address
        app.post '/accounts/:id/verify-email', :provides => [:json] do
          @account = protected!(lambda { |account| account.pk == params[:id].to_i })
          @account.verify_email(params)
          rabl :'accounts/show'
        end

        # Destroy account
        app.delete '/accounts/:id', :provides => [:json] do
          @account = protected!(lambda { |account| account.pk == params[:id].to_i })

          @account.remove_all_roles
          @account.destroy

          204
        end

        # Authorize by email and password
        app.post '/accounts/auth', :provides => [:json] do
          @account = Account.authorize(params)
          rabl :'accounts/auth'
        end

      end
    end
  end
end
