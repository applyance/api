module Applyance
  class Thread < Sequel::Model

    include Applyance::Lib::Tokens

    many_to_one :citizen, :class => :'Applyance::Citizen'
    one_to_many :messages, :class => :'Applyance::Message'

    def before_validation
      super
      self.set_token(:reply_digest)
    end
  end
end
