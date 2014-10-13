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
        self.set(key => self.generate_token(key))
      end

      # Generate, set, and then save a token
      def create_token(key)
        set_token(key)
        self.save
      end

      # Generate a token and make sure it is unique based on the key specified
      def generate_pin(key)
        pin = ""
        loop do
          pin = friendly_pin(4)
          break pin unless self.class.where(key => pin).count > 0
        end
        pin
      end

      # Generate and then set a token
      def set_pin(key)
        self.set(key => self.generate_pin(key))
      end

      # Generate, set, and then save a pin
      def create_pin(key)
        set_pin(key)
        self.save
      end

      # Return a friendly token (used for temporary passwords and the like)
      def friendly_token(length = 8)
        Array.new(length){[*'0'..'9', *'a'..'z', *'A'..'Z'].sample}.join
      end

      # Return a friendly token (used for temporary passwords and the like)
      def friendly_pin(length = 4)
        Array.new(length){[*'0'..'9'].sample}.join
      end

    end
  end
end

Applyance::Lib::Tokens.module_eval do
  module_function(:friendly_token)
  public :friendly_token
end
