module Applyance
  module Routing
    module Errors
      def self.registered(app)

        app.not_found do
          @status = 404
          @title = "Not Found"
          @detail = "We were unable to find this resource on our server."

          rabl :'error', :content_type => :json
        end

        app.error Sequel::ValidationFailed do
          @status = 400
          @title = "Bad Request"
          @detail = env['sinatra.error'].message

          status @status
          rabl :'error', :content_type => :json
        end

        app.error BadRequestError do
          @status = 400
          @title = "Bad Request"
          @detail = env['sinatra.error'].object[:detail]

          status @status
          rabl :'error', :content_type => :json
        end

        app.error ForbiddenError do
          @status = 403
          @title = "Forbidden"
          @detail = "Not authorized to make this request."

          status @status
          rabl :'error', :content_type => :json
        end

        app.error InternalServerError do
          @status = 500
          @title = "Internal Server Error"
          @detail = env['sinatra.error'].object[:detail]

          status @status
          rabl :'error', :content_type => :json
        end

        app.error 400 do
          @status = 400
          @title = "Bad Request"
          @detail = "The request could not be understood by the server due to malformed syntax. The client should not repeat the request without modifications."
          
          rabl :'error', :content_type => :json
        end

        app.error 401 do
          @status = 401
          @title = "Unauthorized"
          @detail = "The client should retry the request with a suitable Authorization header."

          rabl :'error', :content_type => :json
        end

        app.error 403 do
          @status = 403
          @title = "Forbidden"
          @detail = "Not authorized to make this request."

          rabl :'error', :content_type => :json
        end

        app.error 500 do
          @status = 500
          @title = "Internal Server Error"
          @detail = env['sinatra.error'].message

          rabl :'error', :content_type => :json
        end

      end
    end
  end
end
