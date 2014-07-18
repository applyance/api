module Applyance
  class Stage < Sequel::Model
    many_to_one :pipeline, :class => :'Applyance::Pipeline'
    one_to_many :applications, :class => :'Applyance::Application'
  end
end
