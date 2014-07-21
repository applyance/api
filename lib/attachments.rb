module Applyance
  module Lib
    module Attachments

      def attach(params, property = :attachment)
        return if params.nil?

        if params.is_a?(Array)
          # Clear old attachments
          self.send("#{property.to_s}_dataset").delete
          self.send("remove_all_#{property.to_s}")

          params.each { |attachment| attach_single(attachment, "add_#{property.to_s.singularize}") }
        else
          attach_single(params, "#{property.to_s}=")
        end

        # Save changes to the object
        self.save
      end

      private

        def attach_single(params, property)

          if params['token'].nil? || params['name'].nil?
            raise BadRequestError({ :detail => "Attachments must contain a token and a name." })
          end

          s3 = AWS::S3.new(
            :access_key_id => Applyance::Server.settings.aws_s3_access_key_id,
            :secret_access_key => Applyance::Server.settings.aws_s3_secret_access_key
          )

          token = params['token']
          name = params['name']
          source = s3.buckets['applyance.attachments'].objects[token]

          # Create attachment
          attachment = Attachment.create(
            :token => token,
            :name => params['name'],
            :url => source.public_url({ :secure => true }),
            :content_type => source.content_type,
            :byte_size => source.content_length
          )

          # Associate the attachment
          self.send(property, attachment)

        end

    end
  end
end
