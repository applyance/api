module Applyance
  module Helpers
    module Security

      # Retrieve the current account for the request
      def current_account
        @__current_account ||= _current_account
      end

      # Ensure this request is coming from AJAX
      def ensure_xhr!
        error 401 unless request.xhr?
      end

      # Ensure this request is coming from a server
      def ensure_not_xhr!
        error 401 if request.xhr?
      end

      # Ensure this request is coming from https
      def ensure_ssl!
        error 401 unless request.secure?
      end

      #
      # Basic API Key Authentication
      # Authorization takes place in the controller action. This authenticates
      # based on the authorization header and loads the proper account.
      #
      # e.g.
      # protected!(lambda { |account| account.pk == params['id'].to_i })
      #
      def protected!(fn = nil)
        account = current_account
        error 401 unless account && (account.has_role?("chief") || (!fn.nil? && fn.call(account)))
        account
      end

      #
      # Establish a paywall for the specified entity and feature.
      #
      def paywall!(entity, feature)
        return if current_account && current_account.has_role?("chief")
        error 401 unless entity.customer.plan.features.collect(&:name).include?(feature)
      end

      private

        def _current_account
          return nil unless request.env['HTTP_AUTHORIZATION']
          api_key = request.env['HTTP_AUTHORIZATION'].split('auth=')[1]
          Account.first(:api_key => api_key)
        end

    end
  end
end
