module Applyance
  module Helpers
    module Media

      # Upload a specified file and filename to Amazon S3
      def s3_new_attachment(token, data, opts)
        s3 = Applyance::Server::S3
        s3.buckets['applyance.attachments'].objects[token].write(data, opts)
      end

      def s3_attachment(token)
        s3 = Applyance::Server::S3
        s3.buckets['applyance.attachments'].objects[token]
      end

    end
  end
end
