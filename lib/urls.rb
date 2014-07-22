module Applyance
  module Lib
    module URLs

      # Output the URL based on the current hostname
      def client_url_for(request, path)
        if request.referrer.empty?
          "#{request.scheme}://#{request.host}#{request.port.nil? ? "" : ":" + request.port}#{path}"
        end
        uri = URI(request.referrer)
        "#{uri.scheme}://#{uri.host}#{uri.port.nil? ? "" : ":" + uri.port}#{path}"
      end

    end
  end
end
