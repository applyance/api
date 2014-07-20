module Applyance
  module Routing
    module Attachments
      def self.registered(app)

        # Create a new attachment
        app.post '/attachments', :provides => [:json] do

          data = request.body.read

          @token = Digest::MD5.hexdigest(data)
          file = Tempfile.new(@token)
          file.write(data)

          s3_new_attachment(
            @token,
            file, {
              :content_type => request.content_type,
              :content_length => file.length.to_i,
              :acl => :public_read
            }
          )

          file.close
          file.unlink

          rabl :'attachments/create'
        end

      end
    end
  end
end
