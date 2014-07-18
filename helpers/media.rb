module Applyance
  module Helpers
    module Media

      # Upload a specified file and filename to Amazon S3
      def upload_to_s3(filename, file)
        s3 = AWS::S3.new(
          :access_key_id => Applyance::Server.settings.aws_s3_access_key_id,
          :secret_access_key => Applyance::Server.settings.aws_s3_secret_access_key
        )
        s3.buckets['bucket_name'].objects[filname].write(file)
        filename
      end

    end
  end
end
