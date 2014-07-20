module Applyance
  module Lib
    module Tokens

      # Generate a token and make sure it is unique based on the key specified
      def generate_token(key)
        token = ""
        loop do
          token = SecureRandom.urlsafe_base64(nil, false)
          break token unless self.class.where(key => token).count > 0
        end
        token
      end

      # Generate and then set a token
      def set_token(key)
        self.set(key => token)
      end

      # Generate, set, and then save a token
      def create_token(key)
        self.set(key => token)
        self.save
      end

    end
  end
end
