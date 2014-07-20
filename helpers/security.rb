module Applyance
  module Helpers
    module Security

      def current_account
        return Applyance::Server._account if defined?(Applyance::Server._account)
        nil unless request.env['HTTP_AUTHORIZATION']
        api_key = request.env['HTTP_AUTHORIZATION'].split('auth=')[1]
        Applyance::Server._account = Account.first(:api_key => api_key)
        Applyance::Server._account
      end
      
      def ensure_xhr!
        error 401 unless request.xhr?
      end

      def ensure_not_xhr!
        error 401 if request.xhr?
      end

      #
      # Basic API Key Authentication
      # Authorization takes place in the controller action. This authenticates
      # based on the authorization header and loads the proper account.
      #
      # e.g.
      # protected!(lambda { |account| account.pk == params[:id].to_i })
      #
      def protected!(fn = nil)
        account = current_account
        error 401 unless account && (account.has_role?("chief") || (!fn.nil? && fn.call(account)))
        account
      end

    end
  end
end
