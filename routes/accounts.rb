module Applyance
  module Routing
    module Accounts

      module Protection
        # Protection for current account only
        def to_account_id(id)
          lambda { |account| account.id == id.to_i }
        end
      end

      def self.registered(app)

        app.extend(Applyance::Routing::Accounts::Protection)

        # Authenticate by email and password
        app.post '/accounts/auth', :provides => [:json] do
          @account = Account.authenticate(params)

          response.headers["Authorization"] = "ApplyanceLogin auth=#{@account.api_key}"
          @admins = Admin.where(:account_id => @account.id)
          @reviewers = Reviewer.where(:account_id => @account.id)

          rabl :'accounts/me'
        end

        # Return account data
        app.get '/accounts/me', :provides => [:json] do
          @account = protected!(lambda { |a| true })

          @admins = Admin.where(:account_id => @account.id)
          @reviewers = Reviewer.where(:account_id => @account.id)

          rabl :'accounts/me'
        end

        # Show an account specified by Id
        app.get '/accounts/:id', :provides => [:json] do
          @account = protected! app.to_account_id(params['id'])
          rabl :'accounts/show'
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
          @account.datums_dataset.destroy
          @account.reviewers_dataset.destroy
          @account.admins_dataset.destroy
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
        end

        # Set password
        app.post '/accounts/passwords/set', :provides => [:json] do
          @account = Account.first(:reset_digest => params['reset_digest'])
          unless @account
            raise BadRequestError({ detail: "Invalid reset token." })
          end
          @account.set_password(params)
        end

        # Verify email address
        app.post '/accounts/verify', :provides => [:json] do
          @account = Account.first(:verify_digest => params['verify_digest'])
          unless @account
            raise BadRequestError({ :detail => "Invalid verify digest." })
          end
          @account.verify_email(params)
          rabl :'accounts/show'
        end

      end
    end
  end
end
