module Applyance
  module Helpers
    module Media

      # Initialize s3
      def s3_init
        AWS::S3.new(
          :access_key_id => settings.aws_s3_access_key_id,
          :secret_access_key => settings.aws_s3_secret_access_key
        )
      end

      # Upload a specified file and filename to Amazon S3
      def s3_new_attachment(token, data, opts)
        s3 = s3_init
        s3.buckets['applyance.attachments'].objects[token].write(data, opts)
      end

      # Initialize s3
      def s3_attachment(token)
        s3 = s3_init
        s3.buckets['applyance.attachments'].objects[token]
      end

    end
  end
end
