module Applyance
  module Routing
    module Answers
      def self.registered(app)

        # Protection to account
        to_account_owner = lambda do |account_2|
          lambda do |account|
            account.id == account_2.id
          end
        end

        # List answers for account
        # Must be account owner
        app.get '/accounts/:id/answers', :provides => [:json] do
          @account = Account.first(:id => params[:id])
          protected! to_account_owner(@account)
          @answers = @account.answers
          rabl :'answers/index'
        end

        # Create a new answer for an account
        # Must be account owner
        app.post '/accounts/:id/answers', :provides => [:json] do
          @account = Account.first(:id => params[:id])
          protected! to_account_owner(@account)

          @answer = Answer.new
          @answer.set(:account_id => @account.id)
          @answer.set_fields(params, [:definition_id, :answer], :missing => :skip)
          @answer.save
          @answer.attach(params[:attachments], :attachments)

          status 201
          rabl :'answers/show'
        end

        # Get answer by Id
        app.get '/answers/:id', :provides => [:json] do
          @answer = Answer.first(:id => params[:id])
          rabl :'answers/show'
        end

        # Update an answer by Id
        # Must be an account owner
        app.put '/answers/:id', :provides => [:json] do
          @answer = Answer.first(:id => params[:id])
          protected! to_account_owner(@answer.account)

          @answer.update_fields(params, [:answer], :missing => :skip)
          @answer.attach(params[:attachments], :attachments)
          rabl :'answers/show'
        end

        # Delete an answer by Id
        # Must be account owner
        app.delete '/answers/:id', :provides => [:json] do
          @answer = Answer.first(:id => params[:id])

          protected! to_account_owner(@answer.account)

          @answer.remove_all_attachments
          @answer.destroy

          204
        end

      end
    end
  end
end
