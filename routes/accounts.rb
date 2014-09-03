module Applyance
  module Routing
    module Accounts

      def self.registered(app)

        # Return all accounts
        # (for administrative purposes)
        app.get '/accounts', :provides => [:json] do
          protected!
          @accounts = Account.reverse_order(:created_at).all
          rabl :'accounts/index'
        end

        # Authenticate by email and password
        app.post '/accounts/auth', :provides => [:json] do
          @account = Account.authenticate(params)
          response.headers["Authorization"] = "ApplyanceLogin auth=#{@account.api_key}"
          rabl :'accounts/me'
        end

        # Return account data
        app.get '/accounts/me', :provides => [:json] do
          @account = protected!(lambda { |a| true })
          rabl :'accounts/me'
        end

        # Show an account specified by Id
        app.get '/accounts/:id', :provides => [:json] do
          @account = protected! app.to_account_id(params['id'])
          rabl :'accounts/show'
        end

        # See if an email exists
        app.get '/emails', :provides => [:json] do
          if params[:email].nil?
            raise BadRequestError.new({ :detail => "Email required." })
          end
          @account = Account.first(:email => params[:email])
          status = @account.nil? ? 404 : 200
          status
        end

        # Update an account specified by Id
        app.put '/accounts/:id', :provides => [:json] do
          @account = protected! app.to_account_id(params['id'])
          @account.handle_update(params)
          rabl :'accounts/show'
        end

        # Destroy account
        app.delete '/accounts/:id', :provides => [:json] do
          @account = protected! app.to_account_id(params['id'])

          @account.remove_all_roles
          @account.reviewers_dataset.destroy
          @account.destroy

          204
        end

        # Reset password
        app.post '/accounts/passwords/reset', :provides => [:json] do
          @account = Account.first(:email => params['email'])
          unless @account
            raise BadRequestError({ detail: "An account with that email does not exist." })
          end
          @account.reset_password
          200
        end

        # Set password
        app.post '/accounts/passwords/set', :provides => [:json] do
          @account = Account.first(:reset_digest => params['reset_digest'])
          unless @account
            raise BadRequestError({ detail: "Invalid reset token." })
          end
          @account.set_password(params)
          response.headers["Authorization"] = "ApplyanceLogin auth=#{@account.api_key}"
          rabl :'accounts/show'
        end

        # Verify email address
        app.post '/accounts/verify', :provides => [:json] do
          @account = Account.first(:verify_digest => params['verify_digest'])
          unless @account
            raise BadRequestError({ :detail => "Invalid verify digest." })
          end
          @account.verify_email(params)
          response.headers["Authorization"] = "ApplyanceLogin auth=#{@account.api_key}"
          rabl :'accounts/show'
        end

      end
    end
  end
end
