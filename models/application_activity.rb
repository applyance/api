module Applyance
  class ApplicationActivity < Sequel::Model
    many_to_one :application, :class => :'Applyance::Application'
  end
end
