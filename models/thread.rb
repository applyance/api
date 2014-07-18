module Applyance
  class Thread < Sequel::Model
    many_to_one :application, :class => :'Applyance::Application'
    one_to_many :messages, :class => :'Applyance::Message'
  end
end
