module Applyance
  module Routing
    module Accounts
      def self.registered(app)

        # Protection for current account only
        to_account_id = lambda do |id|
          lambda { |account| account.id == id.to_i }
        end

        # Register an account as a reviewer
        app.post '/reviewers/register', :provides => [:json] do
          @account = Account.register("admin", params)
          @entity = Entity.register(@account, params)
          status 201
          rabl :'accounts/reviewers/create'
        end

        # Show an account specified by Id
        app.get '/accounts/:id', :provides => [:json] do
          @account = protected! to_account_id(params[:id])
          rabl :'accounts/show'
        end

        # Update an account specified by Id
        app.put '/accounts/:id', :provides => [:json] do
          @account = protected! to_account_id(params[:id])

          @account.update_fields(params, [:name], :missing => :skip)
          @account.attach(params[:avatar], :avatar)
          rable :'accounts/show'
        end

        # Reset password
        app.post '/accounts/reset-password', :provides => [:json] do
          @account = Account.first(:email => params[:email])
          unless @account
            raise BadRequestError({ detail: "An account with that email does not exist." })
          end
          @account.reset_password
          201
        end

        # Set password
        app.post '/accounts/set-password', :provides => [:json] do
          @account = Account.first(:reset_digest => params[:reset_digest])
          unless @account
            raise BadRequestError({ detail: "Invalid reset token." })
          end
          @account.set_password(params)
          201
        end

        # Change password
        app.post '/accounts/:id/change-password', :provides => [:json] do
          @account = protected! to_account_id(params[:id])
          @account.change_password(params)
          rabl :'accounts/show'
        end

        # Change email address
        app.post '/accounts/:id/change-email', :provides => [:json] do
          @account = protected! to_account_id(params[:id])
          @account.change_email(params)
          rabl :'accounts/show'
        end

        # Verify email address
        app.post '/accounts/verify-email', :provides => [:json] do
          @account.verify_email(params)
          rabl :'accounts/show'
        end

        # Destroy account
        app.delete '/accounts/:id', :provides => [:json] do
          @account = protected! to_account_id(params[:id])

          @account.remove_all_roles
          @account.destroy

          204
        end

        # Authorize by email and password
        app.post '/accounts/auth', :provides => [:json] do
          @account = Account.authenticate(params)
          rabl :'accounts/auth'
        end

      end
    end
  end
end
